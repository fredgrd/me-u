//
//  ChatVC.swift
//  me&us
//
//  Created by Federico on 12/02/23.
//

import UIKit
import Combine

class ChatVC: UIViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<ChatVCViewModel.ChatSection, RoomMessage>
    typealias Snapshot = NSDiffableDataSourceSnapshot<ChatVCViewModel.ChatSection, RoomMessage>
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let viewModel: ChatVCViewModel
    
    private var bag = Set<AnyCancellable>()
    
    private let whitespaceRegex = NSRegularExpression("^[ \t]+|[ \t]+$")
    
    private var firstLoad: Bool = true
    
    // Observers
    private var keyboardWillShowObserver: NSObjectProtocol?
    private var keyboardWillHideObserver: NSObjectProtocol?
    private var appWillEnterBackground: NSObjectProtocol?
    private var appWillEnterForeground: NSObjectProtocol?
    
    // Subviews
    private let draggableBar = UIView()
    private let headerBar = CVCHeader()
    private let footerBar = UIView()
    private var footerBarBotConstraint = NSLayoutConstraint()
    private let inputField = CVCInputField()
    private let sendButton = IconButton()
    
    private var chatCollection: UICollectionView!
    private var chatDataSource: DataSource!
    
    // Init
    init(viewModel: ChatVCViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupObservers()
        setupDataSource()
        
        bindUI()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewOnClick))
        view.addGestureRecognizer(tapRecognizer)
        
        Task {
            await viewModel.fetchHistory()
        }
        
        viewModel.subscribeToRoom()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.subscribeToRoom()
        
        UIView.animate(withDuration: 0.2, delay: 0) {
            self.chatCollection.alpha = 1
        }
    }
    
    deinit {
        viewModel.closeSocket()
        
        guard let keyboardWillShowObserver = keyboardWillShowObserver, let keyboardWillHideObserver = keyboardWillHideObserver, let appWillEnterForeground = appWillEnterForeground, let appWillEnterBackground = appWillEnterBackground else {
            return
        }
        
        NotificationCenter.default.removeObserver(keyboardWillShowObserver)
        NotificationCenter.default.removeObserver(keyboardWillHideObserver)
        NotificationCenter.default.removeObserver(appWillEnterForeground)
        NotificationCenter.default.removeObserver(appWillEnterBackground)
    }
    
    @objc private func viewOnClick() {
        inputField.resignFirstResponder()
    }
    
    private func setupObservers() {
        keyboardWillShowObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { notification in
            guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
            }
            
            self.footerBarBotConstraint.constant = -(keyboardFrame.height - self.view.safeAreaBottom)
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
        
        keyboardWillHideObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { notification in
            self.footerBarBotConstraint.constant = 0
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
        
        appWillEnterForeground = NotificationCenter.default.addObserver(forName: UIScene.willEnterForegroundNotification, object: nil, queue: nil, using: { [weak self] _ in
            Task {
                await self?.viewModel.fetchHistory()
            }
            
            self?.viewModel.subscribeToRoom()
        })
        
        appWillEnterBackground = NotificationCenter.default.addObserver(forName: UIScene.didEnterBackgroundNotification, object: nil, queue: nil, using: { [weak self] _ in
            self?.viewModel.closeSocket()
        })
    }
    
    private func bindUI() {
        // Messages
        viewModel.messages.receive(on: DispatchQueue.main).sink { messages in
            self.updateSnapshot(messages)
        }.store(in: &bag)
        
        // Updates
        viewModel.typing.receive(on: RunLoop.main).sink { update in
            if let update = update {
                self.headerBar.showTyping(update.sender_name)
            } else {
                self.headerBar.hideTyping()
            }
        }.store(in: &bag)
        
        //  Message sending
        sendButton.onClick.receive(on: DispatchQueue.main).sink { button in
            guard let text = self.inputField.text else {
                return
            }
            
            let cleanedText = self.whitespaceRegex.replace(text, with: "")

            Task {
                await self.viewModel.sendMessage(cleanedText)
            }
            
            self.inputField.text = nil
        }.store(in: &bag)
    }
    
    private func setupDataSource() {
        chatDataSource = DataSource(collectionView: chatCollection, cellProvider: { collectionView, indexPath, message in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CVCChatBubbleCell.identifier, for: indexPath) as? CVCChatBubbleCell else {
                fatalError("Failed to dequeue cell \(CVCChatBubbleCell.debugDescription())")
            }
            
            guard let user = self.viewModel.controller.userManager.user.value else {
                fatalError("Failed to retrieve user")
            }
            
            let snapshot = self.chatDataSource.snapshot(for: .chat)
            let showAvatar = indexPath.row + 1 < snapshot.items.count ? message.sender != snapshot.items[indexPath.row + 1].sender : true
            
            
            cell.update(withMessage: message, isUser: user.id == message.sender, showAvatar: showAvatar)
            
            return cell
        })
    }
    
    private func updateSnapshot(_ messages: [RoomMessage]) {
        var snapshot = Snapshot()
        
        snapshot.appendSections([.chat])

        
        snapshot.appendItems(messages, toSection: .chat)
        
        chatDataSource.apply(snapshot)
        chatCollection.scrollToItem(at: IndexPath(row: messages.count - 1, section: 0), at: .top, animated: !firstLoad)
        
        if firstLoad {
            firstLoad = false
        }
    }
}

// MARK: - UITextFieldDelegate
extension ChatVC: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else {
            sendButton.isEnabled = false
            return
        }
    
        let cleaned = whitespaceRegex.replace(text, with: "")
        
        if cleaned.count > 0 {
            sendButton.isEnabled = true
            Task {
                await viewModel.sendUpdate()
            }
        } else {
            sendButton.isEnabled = false
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ChatVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let user = viewModel.controller.userManager.user.value else {
            fatalError("Failed to retrieve user")
        }
        
        let message = viewModel.messages.value[indexPath.row]
        
        if (user.id == message.sender) {
            let size = (message.message as NSString).boundingRect(with: CGSize(width: view.frame.width - (60 + 32 + 12), height: .greatestFiniteMagnitude ), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.font(ofSize: 17, weight: .medium)], context:  nil)
            
            return CGSize(width: view.frame.width, height: ceil(size.height + 20))
        } else {
            let size = (message.message as NSString).boundingRect(with: CGSize(width: view.frame.width - (60 + 28 + 6 + 12), height: .greatestFiniteMagnitude ), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.font(ofSize: 17, weight: .medium)], context:  nil)
            return CGSize(width: view.frame.width, height: ceil(size.height + 20))
        }
    }
}

// MARK: - UISetup
private extension ChatVC {
    func setupUI() {
        view.backgroundColor = .primaryBackground
        view.layer.cornerRadius = 40
        
        setupDraggableBar()
        setupHeaderBar()
        setupFooterBar()
        setupChatCollection()
        setupHeaderGradient()
    }
    
    func setupDraggableBar() {
        draggableBar.backgroundColor = nil
        draggableBar.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            draggableBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            draggableBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            draggableBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            draggableBar.heightAnchor.constraint(equalToConstant: 30)]
        
        view.addSubview(draggableBar)
        NSLayoutConstraint.activate(constraints)
        
        let dragbar = UIView()
        dragbar.layer.cornerRadius = 2.5
        dragbar.backgroundColor = .secondaryDarkText
        dragbar.translatesAutoresizingMaskIntoConstraints = false
        let dragbarConstraints = [
            dragbar.centerXAnchor.constraint(equalTo: draggableBar.centerXAnchor),
            dragbar.centerYAnchor.constraint(equalTo: draggableBar.centerYAnchor),
            dragbar.heightAnchor.constraint(equalToConstant: 5),
            dragbar.widthAnchor.constraint(equalToConstant: 34)]
        
        draggableBar.addSubview(dragbar)
        NSLayoutConstraint.activate(dragbarConstraints)
    }
    
    func setupHeaderBar() {
        headerBar.title = viewModel.room.name
        headerBar.backgroundColor = .primaryBackground
        headerBar.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            headerBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            headerBar.topAnchor.constraint(equalTo: draggableBar.bottomAnchor),
            headerBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            headerBar.heightAnchor.constraint(equalToConstant: 44)]
        
        view.addSubview(headerBar)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupHeaderGradient() {
        let headerGradientView = UIView(frame: CGRect(x: 0, y: 74, width: view.frame.width, height: 20))
        headerGradientView.backgroundColor = .primaryBackground
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 20)
        let layer = CAGradientLayer.gradientLayer(for: .fadingMask, in: frame)
        let maskLayer = CALayer()
        maskLayer.frame = frame
        maskLayer.addSublayer(layer)
        headerGradientView.layer.mask = maskLayer
        view.addSubview(headerGradientView)
    }
    
    func setupFooterBar() {
        footerBar.backgroundColor = .secondaryBackground
        footerBar.translatesAutoresizingMaskIntoConstraints = false
        footerBarBotConstraint = footerBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let constraints = [
            footerBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            footerBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            footerBarBotConstraint,
            footerBar.heightAnchor.constraint(equalToConstant: 52 + view.safeAreaBottom)]
        
        view.addSubview(footerBar)
        NSLayoutConstraint.activate(constraints)
        
        inputField.delegate = self
        inputField.font = .font(ofSize: 17, weight: .medium)
        inputField.textColor = .primaryLightText
        inputField.layer.cornerRadius = 15
        inputField.backgroundColor = .primaryBackground
        inputField.keyboardAppearance = .dark
        inputField.layer.borderColor = UIColor.init(hex: "#555555").cgColor
        inputField.layer.borderWidth = 1
        inputField.translatesAutoresizingMaskIntoConstraints = false
        let fieldConstraints = [
            inputField.leftAnchor.constraint(equalTo: footerBar.leftAnchor, constant: 16),
            inputField.topAnchor.constraint(equalTo: footerBar.topAnchor, constant: 8),
            inputField.heightAnchor.constraint(equalToConstant: 36)]
        
        footerBar.addSubview(inputField)
        NSLayoutConstraint.activate(fieldConstraints)
        
        sendButton.isEnabled = false
        sendButton.image = UIImage(named: "send@16pt")
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        let sendConstraints = [
            sendButton.leftAnchor.constraint(equalTo: inputField.rightAnchor, constant: 16),
            sendButton.topAnchor.constraint(equalTo: footerBar.topAnchor, constant: 8),
            sendButton.rightAnchor.constraint(equalTo: footerBar.rightAnchor, constant: -16),
            sendButton.heightAnchor.constraint(equalToConstant: 36),
            sendButton.widthAnchor.constraint(equalToConstant: 36)]
        
        footerBar.addSubview(sendButton)
        NSLayoutConstraint.activate(sendConstraints)
    }
    
    func setupChatCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        
        chatCollection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        chatCollection.delegate = self
        chatCollection.register(CVCChatBubbleCell.self, forCellWithReuseIdentifier: CVCChatBubbleCell.identifier)
        chatCollection.register(CVCDescriptionCell.self, forCellWithReuseIdentifier: CVCDescriptionCell.identifier)
        chatCollection.backgroundColor = .primaryBackground
        chatCollection.alpha = 0
        chatCollection.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            chatCollection.leftAnchor.constraint(equalTo: view.leftAnchor),
            chatCollection.topAnchor.constraint(equalTo: headerBar.bottomAnchor),
            chatCollection.rightAnchor.constraint(equalTo: view.rightAnchor),
            chatCollection.bottomAnchor.constraint(equalTo: footerBar.topAnchor)]
        
        view.addSubview(chatCollection)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupBackgroundView() {
        let backgroundView = UIImageView()
        backgroundView.image = UIImage(named: "chat-pattern@1000pt")
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundView.topAnchor.constraint(equalTo: headerBar.bottomAnchor),
            backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)]
        
        view.addSubview(backgroundView)
        NSLayoutConstraint.activate(constraints)
    }
}
