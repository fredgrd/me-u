//
//  Menu.swift
//  me&us
//
//  Created by Federico on 12/02/23.
//

import UIKit

class Menu: UIView {
    
    let lxContainer = UIView()
    let cxContainer = UIView()
    let rxContainer = UIView()
    
    let userSettingsButton = IconButton()
    let userNotificationsButton = IconButton()
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
        userSettingsButton.image = UIImage(named: "user@16pt")
        userSettingsButton.backgroundColor = .secondaryBackground
        userSettingsButton.layer.cornerRadius = 22
        userSettingsButton.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            userSettingsButton.leftAnchor.constraint(equalTo: lxContainer.leftAnchor),
            userSettingsButton.topAnchor.constraint(equalTo: lxContainer.topAnchor),
            userSettingsButton.rightAnchor.constraint(equalTo: lxContainer.rightAnchor),
            userSettingsButton.bottomAnchor.constraint(equalTo: lxContainer.bottomAnchor),
        ]
        
        lxContainer.addSubview(userSettingsButton)
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
