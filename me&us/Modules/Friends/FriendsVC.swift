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
    private let navigationBar = UIView()
    private let titleBar = UIView()
    private let dynamicSubtitle = DynamicLabel(staticText: "Add your ")
    private let searchBar = UIView()
    private let searchField = UITextField()
    
    private var collectionView: UICollectionView!
    private var dataSource: DataSource!
    
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
        
        Task {
            print("ABOUT TO UPDATE CONTACS")
            await viewModel.updateContactsModel()
            print("ABOUT TO UPDATE REQUEST")
            await viewModel.updateRequestsModel()
        }
        
        bindUI()
    }
    
    private func bindUI() {
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
                
                return cell
            }
            
            if let contact = model as? Contact {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FVCContactCell.identifier, for: indexPath) as?
                        FVCContactCell else {
                    fatalError("Failed to dequeue \(FVCContactCell.debugDescription())")
                }
                
                cell.update(withContact: contact)
                
                cell.addButton.onClick.receive(on: DispatchQueue.main).sink { button in
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
    
                }.store(in: &self.bag)
                
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
            controller.body = ""
            controller.recipients = [to] //Here goes whom you wants to send the message
            controller.messageComposeDelegate = self as? MFMessageComposeViewControllerDelegate
            self.present(controller, animated: true, completion: nil)
        }
        //This is just for testing purpose as when you run in the simulator, you cannot send the message.
        else{
            print("Cannot send the message")
        }
        func messageComposeViewController(controller:
                                          MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
            //Displaying the message screen with animation.
            self.dismiss(animated: true, completion: nil)
        }
        
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
        
        setupNavigationBar()
        setupTitleBar()
        setupDynamicSubtitle()
        setupSearchBar()
        setupCollectionView()
    }
    
    func setupNavigationBar() {
        navigationBar.backgroundColor = nil
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 30)]
        
        view.addSubview(navigationBar)
        NSLayoutConstraint.activate(constraints)
        
        let dragbar = UIView()
        dragbar.layer.cornerRadius = 2.5
        dragbar.backgroundColor = .secondaryDarkText
        dragbar.translatesAutoresizingMaskIntoConstraints = false
        let dragbarConstraints = [
            dragbar.centerXAnchor.constraint(equalTo: navigationBar.centerXAnchor),
            dragbar.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor),
            dragbar.heightAnchor.constraint(equalToConstant: 5),
            dragbar.widthAnchor.constraint(equalToConstant: 34)]
        
        view.addSubview(dragbar)
        NSLayoutConstraint.activate(dragbarConstraints)
    }
    
    func setupTitleBar() {
        titleBar.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            titleBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            titleBar.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            titleBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            titleBar.heightAnchor.constraint(equalToConstant: 50)]
        
        view.addSubview(titleBar)
        NSLayoutConstraint.activate(constraints)
        
        let titleLabel = UILabel()
        titleLabel.font = .font(ofSize: 21, weight: .bold)
        titleLabel.textColor = .primaryText
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
    
    func setupSearchBar() {
        searchBar.layer.cornerRadius = 17
        searchBar.backgroundColor = .secondaryBackground
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        let barConstraints = [
            searchBar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            searchBar.topAnchor.constraint(equalTo: dynamicSubtitle.bottomAnchor, constant: 25),
            searchBar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            searchBar.heightAnchor.constraint(equalToConstant: 50)]
        
        view.addSubview(searchBar)
        NSLayoutConstraint.activate(barConstraints)
        
        searchField.font = .font(ofSize: 17, weight: .semibold)
        searchField.textColor = .primaryText
        searchField.textAlignment = .center
        searchField.attributedPlaceholder = NSAttributedString(string: "Add a new friend", attributes: [.font: UIFont.font(ofSize: 17, weight: .semibold), .foregroundColor: UIColor.primaryText])
        searchField.translatesAutoresizingMaskIntoConstraints = false
        let fieldConstraints = [
            searchField.leftAnchor.constraint(equalTo: searchBar.leftAnchor, constant: 12),
            searchField.topAnchor.constraint(equalTo: searchBar.topAnchor),
            searchField.rightAnchor.constraint(equalTo: searchBar.rightAnchor, constant: -12),
            searchField.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor)]
        
        searchBar.addSubview(searchField)
        NSLayoutConstraint.activate(fieldConstraints)
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
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 2),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)]
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate(constraints)
    }
}
