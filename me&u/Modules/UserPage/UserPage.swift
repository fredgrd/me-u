//
//  UserPage.swift
//  me&us
//
//  Created by Federico on 12/02/23.
//

import UIKit
import Combine

class UserPage: UIView {
    
    typealias DataSource = UICollectionViewDiffableDataSource<RoomKind, Room>
    typealias Snapshot = NSDiffableDataSourceSnapshot<RoomKind, Room>
    
    private let viewModel: UserPageViewModel
    
    private var bag = Set<AnyCancellable>()
    
    // Subviews
    private let userStatusView = UIView()
    private let userStatusLabel = UILabel()
    private let userStatusButton = IconButton()
    
    private var roomsCollection: UICollectionView!
    private var roomsDataSource: DataSource!
    
    private let createRoomButton = UPCreateRoomButton()
    
    
    init(viewModel: UserPageViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
        setupRoomsDataSource()
        bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func willDisplay() {
        Task {
            await viewModel.fetchRooms()
        }
    }
    
    private func bindUI() {
        viewModel.controller.userManager.user.receive(on: RunLoop.main).sink { user in
            guard let user = user else {
                return
            }
            
            self.userStatusLabel.text = user.status
        }.store(in: &bag)
        
        viewModel.controller.userManager.notifications.receive(on: RunLoop.main).sink { notifications in
            let rooms = self.roomsDataSource.snapshot(for: .main).items
            
            for (index, room) in rooms.enumerated() {
                let roomNotifications = notifications.filter({ $0.room_id == room.id })
                let unreadCount = roomNotifications.reduce(0, { $0 + ($1.status == .sent ? 1 : 0)})
                
                if let cell = self.roomsCollection.cellForItem(at: IndexPath(row: index, section: 0)) as? UPRoomCell {
                    cell.notificationsCount = unreadCount
                }
            }
        }.store(in: &bag)
        
        viewModel.rooms.receive(on: DispatchQueue.main).sink { rooms in
            var snapshot = Snapshot()
            
            snapshot.appendSections([.main])
            snapshot.appendItems(rooms)
            
            self.roomsDataSource.apply(snapshot)
        }.store(in: &bag)
        
        userStatusButton.onClick.receive(on: RunLoop.main).sink { button in
            guard let statusView = self.userStatusLabel.snapshotView(afterScreenUpdates: true) else {
                return
            }
            
            let origin = self.userStatusLabel.convert(statusView.frame.origin, to:  self.viewModel.home.view)
            
            let statusVM = StatusVCViewModel(controller: self.viewModel.controller)
            let statusVC = StatusVC(viewModel: statusVM, statusView: statusView, point: origin)
            statusVC.modalTransitionStyle = .crossDissolve
            statusVC.modalPresentationStyle = .overFullScreen
            self.viewModel.home.present(statusVC, animated: true)
        }.store(in: &bag)
        
        createRoomButton.onClick.receive(on: RunLoop.main).sink { button in
            let roomVM = RoomVCViewModel(controller: self.viewModel.controller)
            roomVM.addRoom = { room in
                var rooms = self.viewModel.rooms.value
                rooms.append(room)
                self.viewModel.rooms.send(rooms)
            }
            let roomVC = RoomVC(viewModel: roomVM)
            self.viewModel.home.present(roomVC, animated: true)
        }.store(in: &bag)
    }
    
    private func setupRoomsDataSource() {
        roomsDataSource = DataSource(collectionView: roomsCollection, cellProvider: { collectionView, indexPath, room in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UPRoomCell.identifier, for: indexPath) as? UPRoomCell else {
                fatalError("Failed to dequeue cell \(UPRoomCell.debugDescription())")
            }
            
            cell.update(title: room.name, description: room.description)
            
            cell.notificationsCount = self.viewModel.unreadCount(forRoom: room.id)
            
            cell.dotsAction = {
                guard let rect = self.roomsCollection.layoutAttributesForItem(at: indexPath) else {
                    return
                }
                
                let point = collectionView.convert(rect.frame.origin, to: self.viewModel.home.view)
                
                let cell = self.roomsCollection.cellForItem(at: indexPath)
                let view = cell?.snapshotView(afterScreenUpdates: true)
        
                let roomOptionsVM = RoomOptionsVCViewModel(controller: self.viewModel.controller, roomID: room.id)
                
                roomOptionsVM.deleteRoom = { room in
                    let rooms = self.viewModel.rooms.value.filter({ $0.id != room })
                    self.viewModel.rooms.send(rooms)
                }
                
                let roomOptionsVC = RoomOptionsVC(viewModel: roomOptionsVM, point: point, view: view!)
                roomOptionsVC.modalTransitionStyle = .crossDissolve
                roomOptionsVC.modalPresentationStyle = .overFullScreen
                self.viewModel.home.present(roomOptionsVC, animated: true)
            }
            
            
            return cell
        })
    }
    
}

extension UserPage: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let room = viewModel.rooms.value[indexPath.row]
        
        let name = room.name
        let description = room.description
        
        let nameSize = (name as NSString).boundingRect(with: CGSize(width: frame.width - (32 + 28 + 28 + 24 + 28), height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [ .font: UIFont.font(ofSize: 17, weight: .semibold)], context: nil)
        let descriptionSize = (description as NSString).boundingRect(with: CGSize(width: frame.width - (32 + 28 + 28), height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [ .font: UIFont.font(ofSize: 15, weight: .semibold)], context: nil)
                
        return CGSize(width: frame.width - 32, height: ceil(nameSize.height + descriptionSize.height + 45 + 12))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let room = viewModel.rooms.value[indexPath.row]
        let chatVM = ChatVCViewModel(controller: viewModel.controller, room: room)
        let chatVC = ChatVC(viewModel: chatVM)
        viewModel.home.present(chatVC, animated: true)
    }
}

// MARK: - UISetup
private extension UserPage {
    func setupUI() {
        backgroundColor = .primaryBackground
        
        setupUserStatusView()
        setupRoomsCollection()
        setupHeaderGradient()
        setupCreateRoomButton()
    }
    
    func setupUserStatusView() {
        userStatusView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            userStatusView.topAnchor.constraint(equalTo: topAnchor, constant: 25),
            userStatusView.centerXAnchor.constraint(equalTo: centerXAnchor),
            userStatusView.heightAnchor.constraint(equalToConstant: 120),
            userStatusView.widthAnchor.constraint(equalToConstant: 120)]
        
        addSubview(userStatusView)
        NSLayoutConstraint.activate(constraints)
        
        userStatusLabel.text = "😋"
        userStatusLabel.font = .font(ofSize: 70, weight: .semibold)
        userStatusLabel.textAlignment = .center
        userStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        let labelConstraints = [
            userStatusLabel.centerXAnchor.constraint(equalTo: userStatusView.centerXAnchor),
            userStatusLabel.centerYAnchor.constraint(equalTo: userStatusView.centerYAnchor)]
        
        userStatusView.addSubview(userStatusLabel)
        NSLayoutConstraint.activate(labelConstraints)
        
        userStatusButton.image = UIImage(named: "pencil@14pt")
        userStatusButton.backgroundColor = .secondaryBackground
        userStatusButton.layer.cornerRadius = 17
        userStatusButton.translatesAutoresizingMaskIntoConstraints = false
        let buttonConstraints = [
            userStatusButton.rightAnchor.constraint(equalTo: userStatusView.rightAnchor),
            userStatusButton.bottomAnchor.constraint(equalTo: userStatusView.bottomAnchor),
            userStatusButton.heightAnchor.constraint(equalToConstant: 34),
            userStatusButton.widthAnchor.constraint(equalToConstant: 34)]
        
        userStatusView.addSubview(userStatusButton)
        NSLayoutConstraint.activate(buttonConstraints)
    }
    
    private func setupRoomsCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: viewModel.home.view.safeAreaBottom + 65, right: 0)
        
        roomsCollection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        roomsCollection.delegate = self
        roomsCollection.register(UPRoomCell.self, forCellWithReuseIdentifier: UPRoomCell.identifier)
        roomsCollection.backgroundColor = .primaryBackground
        roomsCollection.contentInsetAdjustmentBehavior = .never
        roomsCollection.showsVerticalScrollIndicator = false
        roomsCollection.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            roomsCollection.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            roomsCollection.topAnchor.constraint(equalTo: userStatusView.bottomAnchor, constant: 25),
            roomsCollection.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            roomsCollection.bottomAnchor.constraint(equalTo: bottomAnchor)]
        
        addSubview(roomsCollection)
        NSLayoutConstraint.activate(constraints)
    }
    
    
    func setupHeaderGradient() {
        let width = viewModel.home.view.frame.width
        let headerGradientView = UIView(frame: CGRect(x: 0, y: 170, width: width, height: 20))
        headerGradientView.backgroundColor = .primaryBackground
        let frame = CGRect(x: 0, y: 0, width: width, height: 20)
        let layer = CAGradientLayer.gradientLayer(for: .fadingMask, in: frame)
        let maskLayer = CALayer()
        maskLayer.frame = frame
        maskLayer.addSublayer(layer)
        headerGradientView.layer.mask = maskLayer
        addSubview(headerGradientView)
    }
    
    private func setupCreateRoomButton() {
        createRoomButton.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            createRoomButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -(viewModel.home.view.safeAreaBottom + 12)),
            createRoomButton.centerXAnchor.constraint(equalTo: centerXAnchor)]
        
        addSubview(createRoomButton)
        NSLayoutConstraint.activate(constraints)
    }
}
