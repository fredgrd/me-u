//
//  ManageFriendsVC.swift
//  me&us
//
//  Created by Federico on 17/02/23.
//

import UIKit
import Combine

class ManageFriendsVC: UIViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<ManageFriendsVCViewModel.Section, UserFriendDetails>
    typealias Snapshot = NSDiffableDataSourceSnapshot<ManageFriendsVCViewModel.Section, UserFriendDetails>
    
    let viewModel: ManageFriendsVCViewModel
    
    private var bag = Set<AnyCancellable>()
    
    // Subviews
    private let draggableBar = UIView()
    private let titleBar = UIView()
    private var friendsCollection: UICollectionView!
    private var friendsDataSource: DataSource!
    
    // Init
    init(viewModel: ManageFriendsVCViewModel) {
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
        viewModel.controller.userManager.user.receive(on: RunLoop.main).sink { user in
            guard let user = user else {
                fatalError("Failed to retrieve user")
            }
            
            self.setupSnapshot(withDetails: user.friends)
        }.store(in: &bag)
    }
    
    private func setupDataSource() {
        friendsDataSource = DataSource(collectionView: friendsCollection, cellProvider: { collectionView, indexPath, details in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MFVCFriendCell.identifier, for: indexPath) as? MFVCFriendCell else {
                fatalError("Failed to dequeue cell \(MFVCFriendCell.debugDescription())")
            }
            
            cell.update(withDetails: details)
            
            cell.deleteAction = {
                self.presentDeleteAlert(forDetails: details)
            }
            
            return cell
        })
    }
    
    private func setupSnapshot(withDetails details: [UserFriendDetails]) {
        var snapshot = Snapshot()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(details, toSection: .main)
        
        friendsDataSource.apply(snapshot)
    }
    
    private func presentDeleteAlert(forDetails details: UserFriendDetails) {
        let alertVC = UIAlertController(title: "Delete user", message: "\(details.name) will be deleted from your friends", preferredStyle: .alert)
        alertVC.overrideUserInterfaceStyle = .dark
        
        // Delete action
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] action in
            guard let self = self else {
                return
            }
            
            Task {
                await self.viewModel.deleteFriend(withID: details.id)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertVC.addAction(deleteAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ManageFriendsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 76)
    }
}

// MARK: - UISetup
private extension ManageFriendsVC {
    func setupUI() {
        view.layer.cornerRadius = 40
        view.backgroundColor = .primaryBackground
        
        setupDraggableBar()
        setupTitleBar()
        setupFriendsCollection()
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
        titleLabel.text = "Manage your friends"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let titleConstraints = [
            titleLabel.leftAnchor.constraint(equalTo: titleBar.leftAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: titleBar.rightAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: titleBar.centerYAnchor)]
        
        titleBar.addSubview(titleLabel)
        NSLayoutConstraint.activate(titleConstraints)
    }
    
    func setupFriendsCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        friendsCollection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        friendsCollection.delegate = self
        friendsCollection.register(MFVCFriendCell.self, forCellWithReuseIdentifier: MFVCFriendCell.identifier)
        friendsCollection.backgroundColor = .primaryBackground
        friendsCollection.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            friendsCollection.topAnchor.constraint(equalTo: titleBar.bottomAnchor),
            friendsCollection.rightAnchor.constraint(equalTo: view.rightAnchor),
            friendsCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            friendsCollection.leftAnchor.constraint(equalTo: view.leftAnchor)]
        
        view.addSubview(friendsCollection)
        NSLayoutConstraint.activate(constraints)
    }
}
