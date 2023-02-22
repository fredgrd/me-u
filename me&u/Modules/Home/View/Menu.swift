//
//  Menu.swift
//  me&us
//
//  Created by Federico on 12/02/23.
//

import UIKit
import Combine

class Menu: UIView {
    
    var notificationCount: Int = 0 {
        didSet {
            userNotificationIndicator.isHidden = notificationCount == 0
        }
    }
    
    let lxContainer = UIView()
    let cxContainer = UIView()
    let rxContainer = UIView()
    
    let userProfileButton = IconButton()
    let userNotificationsButton = IconButton()
    let userNotificationIndicator = UIView()
    let addFriendButton = HVCAddFriendButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UISetup
private extension Menu {
    func setupUI() {
        backgroundColor = .primaryBackground
        
        setupContainers()
        setupUserSettingsButton()
        setupUserNotificationsButton()
        setupAddFriendButton()
    }
    
    func setupContainers() {
        lxContainer.translatesAutoresizingMaskIntoConstraints = false
        let lxConstraints = [
            lxContainer.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            lxContainer.topAnchor.constraint(equalTo: topAnchor),
            lxContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            lxContainer.widthAnchor.constraint(equalToConstant: 44),
            lxContainer.heightAnchor.constraint(equalToConstant: 44)]
        
        addSubview(lxContainer)
        NSLayoutConstraint.activate(lxConstraints)
        
        cxContainer.translatesAutoresizingMaskIntoConstraints = false
        let cxConstraints = [
            cxContainer.leftAnchor.constraint(equalTo: lxContainer.rightAnchor, constant: 16),
            cxContainer.topAnchor.constraint(equalTo: topAnchor),
            cxContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            cxContainer.heightAnchor.constraint(equalToConstant: 44)]
        
        addSubview(cxContainer)
        NSLayoutConstraint.activate(cxConstraints)
        
        rxContainer.translatesAutoresizingMaskIntoConstraints = false
        let rxConstraints = [
            rxContainer.leftAnchor.constraint(equalTo: cxContainer.rightAnchor, constant: 16),
            rxContainer.topAnchor.constraint(equalTo: topAnchor),
            rxContainer.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            rxContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            rxContainer.widthAnchor.constraint(equalToConstant: 44),
            rxContainer.heightAnchor.constraint(equalToConstant: 44)]
        
        addSubview(rxContainer)
        NSLayoutConstraint.activate(rxConstraints)
    }
    
    private func setupUserSettingsButton() {
        userProfileButton.image = UIImage(named: "user@16pt")
        userProfileButton.backgroundColor = .secondaryBackground
        userProfileButton.layer.cornerRadius = 22
        userProfileButton.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            userProfileButton.leftAnchor.constraint(equalTo: lxContainer.leftAnchor),
            userProfileButton.topAnchor.constraint(equalTo: lxContainer.topAnchor),
            userProfileButton.rightAnchor.constraint(equalTo: lxContainer.rightAnchor),
            userProfileButton.bottomAnchor.constraint(equalTo: lxContainer.bottomAnchor),
        ]
        
        lxContainer.addSubview(userProfileButton)
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupUserNotificationsButton() {
        userNotificationsButton.image = UIImage(named: "notifications@16pt")
        userNotificationsButton.backgroundColor = .secondaryBackground
        userNotificationsButton.layer.cornerRadius = 22
        userNotificationsButton.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            userNotificationsButton.leftAnchor.constraint(equalTo: rxContainer.leftAnchor),
            userNotificationsButton.topAnchor.constraint(equalTo: rxContainer.topAnchor),
            userNotificationsButton.rightAnchor.constraint(equalTo: rxContainer.rightAnchor),
            userNotificationsButton.bottomAnchor.constraint(equalTo: rxContainer.bottomAnchor),
        ]
        
        rxContainer.addSubview(userNotificationsButton)
        NSLayoutConstraint.activate(constraints)
        
        userNotificationIndicator.isHidden = true
        userNotificationIndicator.layer.cornerRadius = 5
        userNotificationIndicator.backgroundColor = .init(hex: "#EC133A")
        userNotificationIndicator.translatesAutoresizingMaskIntoConstraints = false
        let indicatorConstraints = [
            userNotificationIndicator.topAnchor.constraint(equalTo: userNotificationsButton.topAnchor),
            userNotificationIndicator.rightAnchor.constraint(equalTo: userNotificationsButton.rightAnchor),
            userNotificationIndicator.heightAnchor.constraint(equalToConstant: 10),
            userNotificationIndicator.widthAnchor.constraint(equalToConstant: 10)]
        
        rxContainer.addSubview(userNotificationIndicator)
        NSLayoutConstraint.activate(indicatorConstraints)
    }
    
    private func setupAddFriendButton() {
        addFriendButton.backgroundColor = .secondaryBackground
        addFriendButton.layer.cornerRadius = 22
        addFriendButton.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            addFriendButton.centerXAnchor.constraint(equalTo: cxContainer.centerXAnchor),
            addFriendButton.centerYAnchor.constraint(equalTo: cxContainer.centerYAnchor),
            addFriendButton.heightAnchor.constraint(equalToConstant: 44)
        ]
        
        cxContainer.addSubview(addFriendButton)
        NSLayoutConstraint.activate(constraints)
    }
}
