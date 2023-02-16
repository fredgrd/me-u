//
//  FriendsVC.swift
//  me&us
//
//  Created by Federico on 10/02/23.
//

import UIKit
import Combine
import MessageUI

class FriendsVC: UIViewController {
    
    let viewModel: FriendsVCViewModel
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<FriendsVCViewModel.Section, AnyHashable>
    typealias Snapshot = NSDiffableDataSourceSnapshot<FriendsVCViewModel.Section, AnyHashable>
    
    // Subscribers
    private var bag = Set<AnyCancellable>()
    
    // Subviews
    private let draggableBar = UIView()
    private let titleBar = UIView()
    private let dynamicSubtitle = FVCDynamicLabel(staticText: "Add your ")
    
    private var collectionView: UICollectionView!
    private var dataSource: DataSource!
    
    private let permissionRequest = UIView()
    private let permissionButton = PrimaryButton()
    
    // Init
    init(viewModel: FriendsVCViewModel) {
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
        setupDataSource()
        bindUI()
    }
    
    private func bindUI() {
        viewModel.contactsAuthorizationStatus.receive(on: DispatchQueue.main).sink { authorization in
            switch authorization {
            case .authorized:
                self.permissionRequest.isHidden = true
                
                Task {
                    await self.viewModel.updateContactsModel()
                    await self.viewModel.updateRequestsModel()
                }
            default:
                self.permissionRequest.isHidden = false
            }
        }.store(in: &bag)
        
        viewModel.models.receive(on: DispatchQueue.main).sink { models in
            var snapshot = Snapshot()
            
            if !models.receivedRequests.isEmpty {
                snapshot.appendSections([.receivedRequests])
                snapshot.appendItems(models.receivedRequests, toSection: .receivedRequests)
            }
            
            if !models.sentRequests.isEmpty {
                snapshot.appendSections([.sentRequests])
                snapshot.appendItems(models.sentRequests, toSection: .sentRequests)
            }
            
            if !models.contacts.isEmpty {
                snapshot.appendSections([.contacts])
                snapshot.appendItems(models.contacts, toSection: .contacts)
            }
            
            self.dataSource.apply(snapshot)
        }.store(in: &bag)
        
        permissionButton.onClick.receive(on: DispatchQueue.main).sink { button in
            self.viewModel.requestContactsAccess()
        }.store(in: &bag)
    }
    
    private func setupDataSource() {
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, model in
            if let request = model as? FriendRequest {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FVCRequestCell.identifier, for: indexPath) as?
                        FVCRequestCell else {
                    fatalError("Failed to dequeue \(FVCRequestCell.debugDescription())")
                }
                
                guard let user = self.viewModel.controller.userManager.user.value else {
                    fatalError("Failed to retrieve user")
                }
        
                cell.update(request, kind: request.to == user.number ? .received : .sent)
                
                cell.cancelAction = { button in
                    if button.isSpinning { return }
                    button.showSpinner()
                    
                    Task {
                        await self.viewModel.updateRequest(request.id, update: .reject)
                    }
                    
                    button.hideSpinner()
                }
                
                cell.acceptAction = { button in
                    if button.isSpinning { return }
                    button.showSpinner()
                    
                    Task {
                        await self.viewModel.updateRequest(request.id, update: .accept)
                    }
                    
                    button.hideSpinner()
                }
                
                return cell
            }
            
            if let contact = model as? Contact {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FVCContactCell.identifier, for: indexPath) as?
                        FVCContactCell else {
                    fatalError("Failed to dequeue \(FVCContactCell.debugDescription())")
                }
                
                cell.update(withContact: contact)
                
                cell.addAction = { button in
                    if button.isSpinning { return }
                    button.showSpinner()
                    
                    if contact.is_user {
                        Task {
                            await self.viewModel.addContact(contact)
                        }
                    } else {
                        self.sendTextInvite(contact.number)
                    }
                  
                    button.hideSpinner()
                }
                
                return cell
            }
            
            return nil
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else {
                return nil
            }

            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: FVCSectionHeader.identifier, for: indexPath) as? FVCSectionHeader else {
                fatalError("Failed to dequeue \(FVCSectionHeader.debugDescription())")
            }

            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]

            
            if section == .sentRequests {
                header.update(withTitle: section.rawValue, icon: UIImage(named: "checkmark@22pt"))
            }
            
            if section == .receivedRequests {
                header.update(withTitle: section.rawValue, icon: UIImage(named: "request@22pt"))
            }
            
            if section == .contacts {
                header.update(withTitle: section.rawValue, icon: UIImage(named: "message-bubble@22pt"))
            }

            return header
        }
    }
    
    private func sendTextInvite(_ to: String) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "I want to add you me&u. Tap the link to accept 💛 https://meus.com"
            controller.recipients = [to] //Here goes whom you wants to send the message
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
        //This is just for testing purpose as when you run in the simulator, you cannot send the message.
        else{
            viewModel.controller.showToast(withMessage: "Cannot send text")
        }
    }
}

// MARK: - MFMessageComposeViewController
extension FriendsVC: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FriendsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 55)
    }
}

// MARK: - UISetup
private extension FriendsVC {
    func setupUI() {
        view.backgroundColor = .primaryBackground
        view.layer.cornerRadius = 40
        
        setupDraggableBar()
        setupTitleBar()
        setupDynamicSubtitle()
        setupCollectionView()
        setupPermissionRequest()
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
        
        view.addSubview(dragbar)
        NSLayoutConstraint.activate(dragbarConstraints)
    }
    
    func setupTitleBar() {
        titleBar.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            titleBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            titleBar.topAnchor.constraint(equalTo: draggableBar.bottomAnchor),
            titleBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            titleBar.heightAnchor.constraint(equalToConstant: 50)]
        
        view.addSubview(titleBar)
        NSLayoutConstraint.activate(constraints)
        
        let titleLabel = UILabel()
        titleLabel.font = .font(ofSize: 21, weight: .bold)
        titleLabel.textColor = .primaryLightText
        titleLabel.textAlignment = .center
        titleLabel.text = "Pick your best friends"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let titleConstraints = [
            titleLabel.leftAnchor.constraint(equalTo: titleBar.leftAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: titleBar.rightAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: titleBar.centerYAnchor)]
        
        titleBar.addSubview(titleLabel)
        NSLayoutConstraint.activate(titleConstraints)
        
    }
    
    func setupDynamicSubtitle() {
        dynamicSubtitle.setDynamicText("best 🙋‍♂️")
        dynamicSubtitle.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            dynamicSubtitle.topAnchor.constraint(equalTo: titleBar.bottomAnchor),
            dynamicSubtitle.centerXAnchor.constraint(equalTo: view.centerXAnchor)]
        
        view.addSubview(dynamicSubtitle)
        NSLayoutConstraint.activate(constraints)
        
        // Animate
        let values = ["siblings 👧👦", "special 😉","bro 😎", "❤️", "sis 😎", "🐶", "best 🙋‍♂️"]
        var count = 0
        _ = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            self.dynamicSubtitle.animateChange(withText: values[count])
            count = count + 1 >= values.count ? 0 : count + 1
        }
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width, height: 75)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.register(FVCRequestCell.self, forCellWithReuseIdentifier: FVCRequestCell.identifier)
        collectionView.register(FVCContactCell.self, forCellWithReuseIdentifier: FVCContactCell.identifier)
        collectionView.register(FVCSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: FVCSectionHeader.identifier)
        collectionView.backgroundColor = .primaryBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.topAnchor.constraint(equalTo: dynamicSubtitle.bottomAnchor, constant: 5),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)]
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupPermissionRequest() {
        permissionRequest.isHidden = true
        permissionRequest.backgroundColor = .primaryBackground
        permissionRequest.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            permissionRequest.leftAnchor.constraint(equalTo: view.leftAnchor),
            permissionRequest.topAnchor.constraint(equalTo: dynamicSubtitle.bottomAnchor, constant: 5),
            permissionRequest.rightAnchor.constraint(equalTo: view.rightAnchor),
            permissionRequest.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        view.addSubview(permissionRequest)
        NSLayoutConstraint.activate(constraints)
        
        let messageContainer = UIView()
        messageContainer.translatesAutoresizingMaskIntoConstraints = false
        let containerConstraints = [
            messageContainer.topAnchor.constraint(equalTo: permissionRequest.topAnchor, constant: 100),
            messageContainer.centerXAnchor.constraint(equalTo: permissionRequest.centerXAnchor),
            messageContainer.widthAnchor.constraint(equalToConstant: 250)]
        
        permissionRequest.addSubview(messageContainer)
        NSLayoutConstraint.activate(containerConstraints)
        
        // Card
        let card = UIImageView()
        card.image = UIImage(named: "contact-card@65pt")
        card.translatesAutoresizingMaskIntoConstraints = false
        let cardConstraints = [
            card.topAnchor.constraint(equalTo: messageContainer.topAnchor),
            card.centerXAnchor.constraint(equalTo: messageContainer.centerXAnchor)]
        
        messageContainer.addSubview(card)
        NSLayoutConstraint.activate(cardConstraints)
        
        let title = UILabel()
        title.font = .font(ofSize: 21, weight: .bold)
        title.text = "Import your contacts"
        title.textColor = .primaryLightText
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false
        let titleConstraints = [
            title.leftAnchor.constraint(equalTo: messageContainer.leftAnchor),
            title.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 20),
            title.rightAnchor.constraint(equalTo: messageContainer.rightAnchor)]
        
        messageContainer.addSubview(title)
        NSLayoutConstraint.activate(titleConstraints)
        
        let subtitle = UILabel()
        subtitle.font = .font(ofSize: 15, weight: .medium)
        subtitle.text = "Me&u never saves your contacts or texts friends on your behalf"
        subtitle.textColor = .secondaryLightText
        subtitle.textAlignment = .center
        subtitle.numberOfLines = 0
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        let subtitleConstraints = [
            subtitle.leftAnchor.constraint(equalTo: messageContainer.leftAnchor),
            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10),
            subtitle.rightAnchor.constraint(equalTo: messageContainer.rightAnchor)]
        
        messageContainer.addSubview(subtitle)
        NSLayoutConstraint.activate(subtitleConstraints)
        
        permissionButton.title = "Continue"
        permissionButton.translatesAutoresizingMaskIntoConstraints = false
        let permissionButtonConstraints = [
            permissionButton.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 20),
            permissionButton.centerXAnchor.constraint(equalTo: messageContainer.centerXAnchor),
            permissionButton.bottomAnchor.constraint(equalTo: messageContainer.bottomAnchor)
           ]
        
        messageContainer.addSubview(permissionButton)
        NSLayoutConstraint.activate(permissionButtonConstraints)
    }
}
