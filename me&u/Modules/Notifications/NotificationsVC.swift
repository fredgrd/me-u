//
//  NotificationsVC.swift
//  me&u
//
//  Created by Federico on 19/02/23.
//

import UIKit
import Combine

class NotificationsVC: UIViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Notification>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Notification>
    
    private let viewModel: NotificationsVCViewModel
    
    private var bag = Set<AnyCancellable>()
    
    // Subviews
    private let draggableBar = UIView()
    private let goBackButton = IconButton()
    private var notificationsCollection: UICollectionView!
    private var notificationsDatasource: DataSource!
    
    init(viewModel: NotificationsVCViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDataSource()
        bindUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.fetchNotifications()
    }
    
    private func setupDataSource() {
        notificationsDatasource = DataSource(collectionView: notificationsCollection, cellProvider: { collectionView, indexPath, notification in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NVCNotificationCell.identifier, for: indexPath) as? NVCNotificationCell else {
                fatalError("Failed to dequeue cell \(NVCNotificationCell.debugDescription())")
            }
            
            cell.update(withNotification: notification)
            
            return cell
        })
    }
    
    private func setupSnapshot(withNotifications notifications: [Notification]) {
        var snapshot = Snapshot()
        
        snapshot.appendSections([0])
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions.insert(.withFractionalSeconds)
        
        var sortedNotifications = notifications
        sortedNotifications.sort { lhs, rhs in
            let lhsDate = dateFormatter.date(from: lhs.timestamp)!
            let rhsDate = dateFormatter.date(from: rhs.timestamp)!
            
            return lhsDate > rhsDate
        }
        
        snapshot.appendItems(sortedNotifications, toSection: 0)
        
        notificationsDatasource.apply(snapshot)
    }
    
    private func bindUI() {
        goBackButton.onClick.receive(on: RunLoop.main).sink { _ in
            self.viewModel.controller.popViewController(animated: true)
        }.store(in: &bag)
        
        viewModel.notifications.receive(on: RunLoop.main).sink { notifications in
            self.setupSnapshot(withNotifications: notifications)
        }.store(in: &bag)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension NotificationsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let notification = notificationsDatasource.snapshot().itemIdentifiers(inSection: 0)[indexPath.row]
        let size = ("\(notification.sender_name) sent a message in \(notification.room_name)" as NSString).boundingRect(with: CGSize(width: view.frame.width - 80, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.font(ofSize: 17, weight: .semibold)], context: nil)
        
        print("HEIGHT", ceil(size.height))
        
        return CGSize(width: view.frame.width, height: ceil(size.height) + 95)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let notification = notificationsDatasource.snapshot().itemIdentifiers(inSection: 0)[indexPath.row]
        viewModel.updateNotification(notification)
        self.dismiss(animated: true) {
            DeeplinkManager.shared.openUrl(URL(string: "com.meu://home?room_id=\(notification.room_id)")!)
        }
    }
}

// MARK: - UISetup
private extension NotificationsVC {
    func setupUI() {
        view.backgroundColor = .primaryBackground
        view.layer.cornerRadius = 40
        
        setupDraggableBar()
        setuNotificationsCollection()
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
    
    func setuNotificationsCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)

        notificationsCollection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        notificationsCollection.delegate = self
        notificationsCollection.register(NVCNotificationCell.self, forCellWithReuseIdentifier: NVCNotificationCell.identifier)
        notificationsCollection.backgroundColor = .primaryBackground
        notificationsCollection.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            notificationsCollection.leftAnchor.constraint(equalTo: view.leftAnchor),
            notificationsCollection.topAnchor.constraint(equalTo: draggableBar.bottomAnchor),
            notificationsCollection.rightAnchor.constraint(equalTo: view.rightAnchor),
            notificationsCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor)]
        
        view.addSubview(notificationsCollection)
        NSLayoutConstraint.activate(constraints)
    }
}
