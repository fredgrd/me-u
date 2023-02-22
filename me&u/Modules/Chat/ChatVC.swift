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
    private let inputBar = CVCInputBar()
    private var inputBarBotConstraint = NSLayoutConstraint()
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
        self.presentationController?.delegate = self
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
            
            self.inputBarBotConstraint.constant = -(keyboardFrame.height - self.view.safeAreaBottom)
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
        
        keyboardWillHideObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { notification in
            self.inputBarBotConstraint.constant = 0
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
                await self.viewModel.sendMessage(cleanedText, kind: .text)
            }
            
            self.inputField.text = nil
        }.store(in: &bag)
        
        // Input bar
        inputBar.recordingState.receive(on: RunLoop.main).sink { [weak self] state in
            guard let self = self else {
                return
            }
            
            self.handleRecordingState(state)
        }.store(in: &bag)
        
        inputBar.mediaOnClick.receive(on: RunLoop.main).sink { [weak self] _ in
            self?.presentImagePickerOptions()
        }.store(in: &bag)
        
        inputBar.sendOnClick.receive(on: RunLoop.main).sink { [weak self] text in
            self?.viewModel.sendText(text)
        }.store(in: &bag)
    }
    
    private func setupDataSource() {
        chatDataSource = DataSource(collectionView: chatCollection, cellProvider: { collectionView, indexPath, message in
           
            
            guard let user = self.viewModel.controller.userManager.user.value else {
                fatalError("Failed to retrieve user")
            }
            
            let snapshot = self.chatDataSource.snapshot(for: .chat)
            let showAvatar = indexPath.row + 1 < snapshot.items.count ? message.sender != snapshot.items[indexPath.row + 1].sender : true
            
            switch(message.kind, user.id == message.sender) {
            case (.text, true):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CVCUserTextCell.identifier, for: indexPath) as? CVCUserTextCell else {
                    fatalError("Failed to dequeue cell \(CVCUserTextCell.debugDescription())")
                }
                
                cell.update(message.message, showAvatar: showAvatar)
                
                return cell
            case (.text, false):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CVCFriendTextCell.identifier, for: indexPath) as? CVCFriendTextCell else {
                    fatalError("Failed to dequeue cell \(CVCFriendTextCell.debugDescription())")
                }
                
                cell.update(message.message, userName: message.sender_name, avatarUrl: message.sender_thumbnail, showAvatar: showAvatar)
                
                return cell
            case (.audio, true):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CVCUserAudioCell.identifier, for: indexPath) as? CVCUserAudioCell else {
                    fatalError("Failed to dequeue cell \(CVCUserAudioCell.debugDescription())")
                }
                
                cell.update(message.message, showAvatar: showAvatar)
                
                return cell
            case (.audio, false):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CVCFriendAudioCell.identifier, for: indexPath) as? CVCFriendAudioCell else {
                    fatalError("Failed to dequeue cell \(CVCFriendAudioCell.debugDescription())")
                }
                
                cell.update(message.message, userName: message.sender_name, avatarUrl: message.sender_thumbnail, showAvatar: showAvatar)
                
                return cell
            case (.image, true):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CVCUserImageCell.identifier, for: indexPath) as? CVCUserImageCell else {
                    fatalError("Failed to dequeue cell \(CVCUserImageCell.debugDescription())")
                }
                
                cell.update(message.message, showAvatar: showAvatar)
                
                cell.imageOnTap = { cell, frame in
                    self.presentImageFocus(cell: cell, frame: frame, url: message.message)
                }
                
                return cell
            case (.image, false):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CVCFriendImageCell.identifier, for: indexPath) as? CVCFriendImageCell else {
                    fatalError("Failed to dequeue cell \(CVCFriendImageCell.debugDescription())")
                }
                
                cell.update(message.message, userName: message.sender_name, avatarUrl: message.sender_thumbnail, showAvatar: showAvatar)
                
                cell.imageOnTap = { cell, frame in
                    self.presentImageFocus(cell: cell, frame: frame, url: message.message)
                }
                
                return cell
            }
        })
    }
    
    private func updateSnapshot(_ messages: [RoomMessage]) {
        var snapshot = Snapshot()
        
        snapshot.appendSections([.chat])

        snapshot.appendItems(messages, toSection: .chat)
        
        chatDataSource.applySnapshotUsingReloadData(snapshot)
        
        chatCollection.scrollToItem(at: IndexPath(row: messages.count - 1, section: 0), at: .top, animated: !firstLoad)
        
        if firstLoad {
            firstLoad = false
        }
    }
    
    private func imagePicker(sourceType: UIImagePickerController.SourceType) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = sourceType
        return imagePicker
    }
    
    private func presentImagePickerOptions() {
        let alertVC = UIAlertController(title: "Select image", message: "The image is visible to every participant in the room.", preferredStyle: .actionSheet)
        alertVC.overrideUserInterfaceStyle = .dark
        
        // Image picker fro library
        let libraryAction = UIAlertAction(title: "Choose from library", style: .default) { [weak self] action in
            guard let self = self else {
                return
            }
            
            let libraryImagePicker = self.imagePicker(sourceType: .photoLibrary)
            self.present(libraryImagePicker, animated: true)
        }
        
        // Image picker for camera
        let cameraAction = UIAlertAction(title: "Take a photo", style: .default) { [weak self] action in
            guard let self = self else {
                return
            }
            
            let cameraImagePicker = self.imagePicker(sourceType: .camera)
            self.present(cameraImagePicker, animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertVC.addAction(libraryAction)
        alertVC.addAction(cameraAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true)
    }
    
    private func presentImageFocus(cell: UIView, frame: CGRect, url: String) {
        let focusVC = ImageFocusVC(url: url, frame: frame)
        let origin = chatCollection.convert(cell.frame.origin, to: focusVC.view)
      
        print(origin)
        
        guard let snapshot = cell.snapshotView(afterScreenUpdates: true) else {
            viewModel.controller.showToast(withMessage: "Could not show")
            return
        }
        snapshot.frame.origin = origin
        focusVC.setupUI(snapshot)
        
        focusVC.modalTransitionStyle = .crossDissolve
        focusVC.modalPresentationStyle = .overFullScreen
        
        self.present(focusVC, animated: true)
    }
}

// MARK: - Helpers
private extension ChatVC {
    func handleRecordingState(_ state: ChatVCViewModel.RecordingState) {
        if state == .startRecording {
            viewModel.startRecordingSession()
        }
        
        if state == .stopRecording {
            viewModel.resetRecordingSession()
        }
        
        if state == .doneRecording {
            viewModel.completeRecordingSession()
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        if let imageData = image.jpegData(compressionQuality: 0.5) {
            viewModel.uploadImage(imageData)
        }

        picker.dismiss(animated: true)
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

// MARK: - UIAdaptivePresentationControllerDelegate
extension ChatVC: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        viewModel.closeSocket()
        
        guard let keyboardWillShowObserver = keyboardWillShowObserver, let keyboardWillHideObserver = keyboardWillHideObserver, let appWillEnterForeground = appWillEnterForeground, let appWillEnterBackground = appWillEnterBackground else {
            return
        }
        
        NotificationCenter.default.removeObserver(keyboardWillShowObserver)
        NotificationCenter.default.removeObserver(keyboardWillHideObserver)
        NotificationCenter.default.removeObserver(appWillEnterForeground)
        NotificationCenter.default.removeObserver(appWillEnterBackground)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ChatVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let user = viewModel.controller.userManager.user.value else {
            fatalError("Failed to retrieve user")
        }
        
        let message = viewModel.messages.value[indexPath.row]
        
        switch (message.kind, user.id == message.sender) {
        case (.text, true):
            let width = view.frame.width - (60 + 44 + 12)
            let size = (message.message as NSString).boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude ), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.font(ofSize: 16, weight: .regular)], context:  nil)
            
            return CGSize(width: view.frame.width, height: ceil(size.height + 20))
        
        case (.text, false):
            let width = view.frame.width - 150
            let size = (message.message as NSString).boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude ), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.font(ofSize: 16, weight: .regular)], context:  nil)
            
            return CGSize(width: view.frame.width, height: ceil(size.height + 20))
            
        case (.audio, true):
            return CGSize(width: view.frame.width, height: 50)
            
        case (.audio, false):
            return CGSize(width: view.frame.width, height: 50)
            
        case (.image, _):
            return CGSize(width: view.frame.width, height: 260)
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
//        setupFooterBar()
        setupInputBar()
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
    
    func setupInputBar() {
        inputBar.translatesAutoresizingMaskIntoConstraints = false
        inputBarBotConstraint = inputBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let constraints = [
            inputBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            inputBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            inputBarBotConstraint,
            inputBar.heightAnchor.constraint(equalToConstant: 52 + view.safeAreaBottom)]
        
        view.addSubview(inputBar)
        NSLayoutConstraint.activate(constraints)
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
        chatCollection.register(CVCUserTextCell.self, forCellWithReuseIdentifier: CVCUserTextCell.identifier)
        chatCollection.register(CVCFriendTextCell.self, forCellWithReuseIdentifier: CVCFriendTextCell.identifier)
        chatCollection.register(CVCUserAudioCell.self, forCellWithReuseIdentifier: CVCUserAudioCell.identifier)
        chatCollection.register(CVCFriendAudioCell.self, forCellWithReuseIdentifier: CVCFriendAudioCell.identifier)
        chatCollection.register(CVCUserImageCell.self, forCellWithReuseIdentifier: CVCUserImageCell.identifier)
        chatCollection.register(CVCFriendImageCell.self, forCellWithReuseIdentifier: CVCFriendImageCell.identifier)
        chatCollection.backgroundColor = .primaryBackground
        chatCollection.alpha = 0
        chatCollection.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            chatCollection.leftAnchor.constraint(equalTo: view.leftAnchor),
            chatCollection.topAnchor.constraint(equalTo: headerBar.bottomAnchor),
            chatCollection.rightAnchor.constraint(equalTo: view.rightAnchor),
            chatCollection.bottomAnchor.constraint(equalTo: inputBar.topAnchor)]
        
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
