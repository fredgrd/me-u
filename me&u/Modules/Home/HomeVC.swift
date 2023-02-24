//
//  HomeVC.swift
//  me&us
//
//  Created by Federico on 10/02/23.
//

import UIKit
import Combine

class HomeVC: UIViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<HomeVCViewModel.PageKind, String>
    typealias Snapshot = NSDiffableDataSourceSnapshot<HomeVCViewModel.PageKind, String>
    
    private let viewModel: HomeVCViewModel
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private var bag = Set<AnyCancellable>()
    
    // Subviews
    private let menu = Menu()
    
    private var pagesCollection: UICollectionView!
    private var pagesDataSource: DataSource!
    
    // Init
    required init(viewModel: HomeVCViewModel) {
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
        bindUI()
        setupDataSource()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showFriendsVC()
    }
    
    private func showFriendsVC() {
        guard let user = viewModel.controller.userManager.user.value else {
            fatalError("Could not retrieve user")
        }
        
        if (user.friends.isEmpty) {
            let friendsVM = FriendsVCViewModel(controller: viewModel.controller)
            let friendsVC = FriendsVC(viewModel: friendsVM)
            friendsVC.modalTransitionStyle = .coverVertical
            self.present(friendsVC, animated: true)
        }
    }
    
    private func bindUI() {
        menu.userProfileButton.onClick.receive(on: RunLoop.main).sink { _ in
            self.viewModel.controller.goToProfile()
        }.store(in: &bag)
        
        menu.addFriendButton.onClick.receive(on: DispatchQueue.main).sink { _ in
            let friendsVM = FriendsVCViewModel(controller: self.viewModel.controller)
            let friendsVC = FriendsVC(viewModel: friendsVM)
            friendsVC.modalTransitionStyle = .coverVertical
            self.present(friendsVC, animated: true)
        }.store(in: &bag)
        
        menu.userNotificationsButton.onClick.receive(on: RunLoop.main).sink { _ in
            self.viewModel.presentNotificationsVC(from: self)
        }.store(in: &bag)
        
        viewModel.controller.userManager.notifications.receive(on: RunLoop.main).sink { notifications in
            let unreadCount = notifications.reduce(0) { partialResult, notification in
                return partialResult + (notification.status == .sent ? 1 : 0)
            }
            self.menu.notificationCount = unreadCount
        }.store(in: &bag)
        
        viewModel.controller.userManager.user.receive(on: RunLoop.main).sink { user in
            guard let user = user else {
                fatalError("Failed to retrieve user")
            }
            
            self.updateSnapshot(withUser: user)
        }.store(in: &bag)
        
        DeeplinkManager.shared.urlToOpen.receive(on: RunLoop.main).sink { info in
            guard let info = info else {
                return
            }
            
            if info.host == "home", let roomID = info.parameters["room_id"] {
                Task {
                    guard let room = await self.viewModel.fetchRoom(roomID) else {
                        return
                    }
                    
                    let chatVM = ChatVCViewModel(controller: self.viewModel.controller, room: room)
                    let chatVC = ChatVC(viewModel: chatVM)
                    self.presentedViewController?.dismiss(animated: false)
                    self.present(chatVC, animated: true)
                }
//
            }
        }.store(in: &bag)
    }
    
    private func setupDataSource() {
        pagesDataSource = DataSource(collectionView: pagesCollection, cellProvider: { collectionView, indexPath, id in
            guard let user = self.viewModel.controller.userManager.user.value else {
                fatalError("Could not retrieve user")
            }
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HVCPageCell.identifier, for: indexPath) as? HVCPageCell else {
                fatalError("Failed to dequeue cell \(HVCPageCell.debugDescription())")
            }
            
            if user.id == id {
                cell.update(withKind: .user, in: self, controller: self.viewModel.controller)
            } else {
                guard let friend = user.friends.first(where: { $0.id == id }) else {
                    fatalError("Failed to retrieve friend")
                }
                
                cell.update(withKind: .friend, friend: friend, in: self, controller: self.viewModel.controller)
            }
            
          
            
            return cell
        })
    }
    
    private func updateSnapshot(withUser user: User) {
        var snapshot = Snapshot()
        
        snapshot.appendSections([.user, .friend])
        snapshot.appendItems([user.id], toSection: .user)
        snapshot.appendItems(user.friends.map({ $0.id }), toSection: .friend)
        
        pagesDataSource.apply(snapshot)
    }
}

extension HomeVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height - (view.safeAreaTop + 44))
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? HVCPageCell else {
            fatalError("Failed to cast cell \(HVCPageCell.debugDescription())")
        }
        
        cell.willDisplay()
    }
}

// MARK: - UISetup
private extension HomeVC {
    func setupUI() {
        view.backgroundColor = .primaryBackground
        
        setupMenu()
        setupPagesCollection()
    }
    
    func setupMenu() {
        menu.translatesAutoresizingMaskIntoConstraints = false
        let menuConstraints = [
            menu.leftAnchor.constraint(equalTo: view.leftAnchor),
            menu.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            menu.rightAnchor.constraint(equalTo: view.rightAnchor)]
        
        view.addSubview(menu)
        NSLayoutConstraint.activate(menuConstraints)
    }
    
    func setupPagesCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        pagesCollection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        pagesCollection.isPagingEnabled = true
        pagesCollection.delegate = self
        pagesCollection.register(HVCPageCell.self, forCellWithReuseIdentifier: HVCPageCell.identifier)
        pagesCollection.backgroundColor = .primaryBackground
        pagesCollection.contentInsetAdjustmentBehavior = .never
        pagesCollection.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            pagesCollection.leftAnchor.constraint(equalTo: view.leftAnchor),
            pagesCollection.topAnchor.constraint(equalTo: menu.bottomAnchor),
            pagesCollection.rightAnchor.constraint(equalTo: view.rightAnchor),
            pagesCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor)]
        
        view.addSubview(pagesCollection)
        NSLayoutConstraint.activate(constraints)
    }
}
