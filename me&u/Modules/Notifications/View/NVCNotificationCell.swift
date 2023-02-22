//
//  NVCNotificationCell.swift
//  me&u
//
//  Created by Federico on 19/02/23.
//

import UIKit

class NVCNotificationCell: UICollectionViewCell {
    static let identifier = "NVCNotificationCell"
    
    // Subviews
    private let notificationIcon = UIImageView()
    private let avatarView = UIView()
    private let avatarLabel = UILabel()
    private let avatarImage = UIImageView()
    
    private let nameLabel = UILabel()
    private let messageLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarLabel.isHidden = true
        avatarImage.isHidden = true
    }
    
    func update(withNotification notification: Notification) {
        if notification.status == .read {
            notificationIcon.tintColor = .primaryLightText
        } else {
            notificationIcon.tintColor = .init(hex: "#EC133A")
        }
        
        if notification.sender_avatar == "none" {
            avatarLabel.isHidden = false
            avatarLabel.text = notification.sender_name.first?.uppercased()
        } else {
            avatarImage.isHidden = false
            avatarImage.sd_setImage(with: URL(string: notification.sender_avatar))
        }
        
        nameLabel.text = "\(notification.sender_name) sent a message in \(notification.room_name)"
        messageLabel.text = notification.message
    }
}

// MARK: - UISetup
private extension NVCNotificationCell {
    func setupUI() {
        contentView.backgroundColor = .primaryBackground
        
        setupNotificationIcon()
        setupAvatarView()
        setupNameLabel()
        setupMessageLabel()
    }
    
    func setupNotificationIcon() {
        notificationIcon.image = UIImage(named: "message@24pt")
        notificationIcon.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            notificationIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            notificationIcon.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            notificationIcon.heightAnchor.constraint(equalToConstant: 24),
            notificationIcon.widthAnchor.constraint(equalToConstant: 24)]
        
        contentView.addSubview(notificationIcon)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupAvatarView() {
        avatarView.layer.cornerRadius = 15
        avatarView.backgroundColor = .secondaryBackground
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        let viewConstraints = [
            avatarView.centerYAnchor.constraint(equalTo: notificationIcon.centerYAnchor),
            avatarView.leftAnchor.constraint(equalTo: notificationIcon.rightAnchor, constant: 10),
            avatarView.heightAnchor.constraint(equalToConstant: 30),
            avatarView.widthAnchor.constraint(equalToConstant: 30)]
        
        contentView.addSubview(avatarView)
        NSLayoutConstraint.activate(viewConstraints)
        
        // Label
        avatarLabel.isHidden = true
        avatarLabel.font = .font(ofSize: 13, weight: .semibold)
        avatarLabel.textColor = .primaryLightText
        avatarLabel.textAlignment = .center
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        let labelConstraints = [
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor)]
        
        avatarView.addSubview(avatarLabel)
        NSLayoutConstraint.activate(labelConstraints)
        
        // Image
        avatarImage.isHidden = true
        avatarImage.layer.cornerRadius = 15
        avatarImage.layer.masksToBounds = true
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        let imageConstraints = [
            avatarImage.topAnchor.constraint(equalTo: avatarView.topAnchor),
            avatarImage.rightAnchor.constraint(equalTo: avatarView.rightAnchor),
            avatarImage.bottomAnchor.constraint(equalTo: avatarView.bottomAnchor),
            avatarImage.leftAnchor.constraint(equalTo: avatarView.leftAnchor)]
        
        avatarView.addSubview(avatarImage)
        NSLayoutConstraint.activate(imageConstraints)
    }
    
    func setupNameLabel() {
        nameLabel.font = .font(ofSize: 17, weight: .semibold)
        nameLabel.textColor = .primaryLightText
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            nameLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 10),
            nameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -25),
            nameLabel.leftAnchor.constraint(equalTo: avatarView.leftAnchor)]
        
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupMessageLabel() {
        messageLabel.font = .font(ofSize: 15, weight: .medium)
        messageLabel.textColor = .secondaryLightText
        messageLabel.numberOfLines = 1
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            messageLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -25),
            messageLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)]
        
        contentView.addSubview(messageLabel)
        NSLayoutConstraint.activate(constraints)
    }
}
