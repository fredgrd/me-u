//
//  FriendPage.swift
//  me&us
//
//  Created by Federico on 16/02/23.
//

import UIKit
import Combine
import SDWebImage

class FriendPage: UIView {
    
    typealias DataSource = UICollectionViewDiffableDataSource<RoomKind, Room>
    typealias Snapshot = NSDiffableDataSourceSnapshot<RoomKind, Room>
    
    private let viewModel: FriendPageViewModel
    
    private var bag = Set<AnyCancellable>()
    
    // Subviews
    private let friendAvatarView = UIView()
    private let friendInitialLabel = UILabel()
    private let friendAvatarImage = UIImageView()
    private let friendStatusLabel = UILabel()
    
    private var roomsCollection: UICollectionView!
    private var roomsDataSource: DataSource!
    
    init(viewModel: FriendPageViewModel) {
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
        // Fetch friend
        Task {
            let details = await viewModel.fetchFriendDetails()
            
            if let details = details {
                if details.avatar_url != "none" {
                    friendAvatarImage.sd_setImage(with: URL(string: details.avatar_url))
                    friendAvatarImage.isHidden = false
                } else {
                    friendAvatarImage.isHidden = true
                }
                
                friendStatusLabel.text = details.status
            }
            
            await viewModel.fetchRooms()
        }
    }
    
    private func bindUI() {
        viewModel.rooms.receive(on: RunLoop.main).sink { rooms in
            var snapshot = Snapshot()
            
            snapshot.appendSections([.main])
            snapshot.appendItems(rooms)
            
            self.roomsDataSource.apply(snapshot)
        }.store(in: &bag)
    }
    
    private func setupRoomsDataSource() {
        roomsDataSource = DataSource(collectionView: roomsCollection, cellProvider: { collectionView, indexPath, room in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FPRoomCell.identifier, for: indexPath) as? FPRoomCell else {
                fatalError("Failed to dequeue cell \(FPRoomCell.debugDescription())")
            }
            
            cell.update(title: room.name, description: room.description)
            
            return cell
        })
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FriendPage: UICollectionViewDelegateFlowLayout {
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
private extension FriendPage {
    func setupUI() {
        backgroundColor = .primaryBackground
        
        setupFriendAvatarView()
        setupRoomsCollection()
        setupHeaderGradient()
//        setupCreateRoomButton()
    }
    
    func setupFriendAvatarView() {
        friendAvatarView.layer.cornerRadius = 50
        friendAvatarView.backgroundColor = .secondaryBackground
        friendAvatarView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            friendAvatarView.topAnchor.constraint(equalTo: topAnchor, constant: 25),
            friendAvatarView.centerXAnchor.constraint(equalTo: centerXAnchor),
            friendAvatarView.heightAnchor.constraint(equalToConstant: 120),
            friendAvatarView.widthAnchor.constraint(equalToConstant: 120)]
        
        addSubview(friendAvatarView)
        NSLayoutConstraint.activate(constraints)
        
        friendInitialLabel.text = viewModel.friend.name.first?.uppercased() ?? ""
        friendInitialLabel.font = .font(ofSize: 70, weight: .semibold)
        friendInitialLabel.textColor = .primaryLightText
        friendInitialLabel.textAlignment = .center
        friendInitialLabel.translatesAutoresizingMaskIntoConstraints = false
        let labelConstraints = [
            friendInitialLabel.centerXAnchor.constraint(equalTo: friendAvatarView.centerXAnchor),
            friendInitialLabel.centerYAnchor.constraint(equalTo: friendAvatarView.centerYAnchor)]
        
        friendAvatarView.addSubview(friendInitialLabel)
        NSLayoutConstraint.activate(labelConstraints)
        
        friendAvatarImage.isHidden = true
        friendAvatarImage.layer.cornerRadius = 50
        friendAvatarImage.contentMode = .scaleAspectFill
        friendAvatarImage.layer.masksToBounds = true
        friendAvatarImage.translatesAutoresizingMaskIntoConstraints = false
        let imageConstraints = [
            friendAvatarImage.topAnchor.constraint(equalTo: topAnchor, constant: 25),
            friendAvatarImage.centerXAnchor.constraint(equalTo: centerXAnchor),
            friendAvatarImage.heightAnchor.constraint(equalToConstant: 120),
            friendAvatarImage.widthAnchor.constraint(equalToConstant: 120)]
        
        friendAvatarView.addSubview(friendAvatarImage)
        NSLayoutConstraint.activate(imageConstraints)
        
        friendStatusLabel.text = "😋"
        friendStatusLabel.font = .font(ofSize: 40, weight: .semibold)
        friendStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        let statusConstraints = [
            friendStatusLabel.rightAnchor.constraint(equalTo: friendAvatarView.rightAnchor, constant: 8),
            friendStatusLabel.bottomAnchor.constraint(equalTo: friendAvatarView.bottomAnchor, constant: 8)]
        
        friendAvatarView.addSubview(friendStatusLabel)
        NSLayoutConstraint.activate(statusConstraints)
    }
    
    private func setupRoomsCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: viewModel.home.view.safeAreaBottom, right: 0)
        
        roomsCollection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        roomsCollection.delegate = self
        roomsCollection.register(FPRoomCell.self, forCellWithReuseIdentifier: FPRoomCell.identifier)
        roomsCollection.backgroundColor = .primaryBackground
        roomsCollection.contentInsetAdjustmentBehavior = .never
        roomsCollection.showsVerticalScrollIndicator = false
        roomsCollection.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            roomsCollection.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            roomsCollection.topAnchor.constraint(equalTo: friendAvatarView.bottomAnchor, constant: 25),
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
}
