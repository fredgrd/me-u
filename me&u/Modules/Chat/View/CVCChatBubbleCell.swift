//
//  CVCChatBubbleCell.swift
//  me&us
//
//  Created by Federico on 12/02/23.
//

import UIKit

class CVCChatBubbleCell: UICollectionViewCell {
    static let identifier = "CVCChatBubbleCell"
    
    private let userBubble = UIView()
    private let userMessageLabel = UILabel()
    private let friendThumbnailContainer = UIView()
    private let friendThumbnailImage = UIImageView()
    private let friendThumbnailLabel = UILabel()
    private let friendBubble = UIView()
    private let friendMessageLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        friendBubble.isHidden = true
        friendThumbnailContainer.isHidden = true
        friendThumbnailLabel.isHidden = true
        friendThumbnailImage.isHidden = true
        userBubble.isHidden = true
    }
    
    func update(withMessage message: RoomMessage, isUser: Bool, showAvatar: Bool) {
        if isUser {
            userBubble.isHidden = false
            userMessageLabel.text = message.message
        } else {
            friendBubble.isHidden = false
            friendThumbnailContainer.isHidden = !showAvatar
            friendMessageLabel.text = message.message
            
            if showAvatar {
                if message.sender_thumbnail != "none" {
                    friendThumbnailImage.isHidden = false
                    friendThumbnailImage.sd_setImage(with: URL(string: message.sender_thumbnail))
                } else if let first = message.sender_name.first?.uppercased() {
                    friendThumbnailLabel.isHidden = false
                    friendThumbnailLabel.text = first
                }
            }
        }
    }
}


// MARK: - UISetup
private extension CVCChatBubbleCell {
    func setupUI() {
        setupUserBubble()
        setupFriendBubble()
    }
    
    func setupUserBubble() {
        userBubble.isHidden = true
        userBubble.backgroundColor = .init(hex: "#55BB70")
        userBubble.layer.cornerRadius = 20
        userBubble.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            userBubble.leftAnchor.constraint(greaterThanOrEqualTo: contentView.leftAnchor, constant: 60),
            userBubble.topAnchor.constraint(equalTo: contentView.topAnchor),
            userBubble.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -12),
            userBubble.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)]
        
        contentView.addSubview(userBubble)
        NSLayoutConstraint.activate(constraints)
        
        userMessageLabel.font = .font(ofSize: 17, weight: .medium)
        userMessageLabel.textColor = .white
        userMessageLabel.numberOfLines = 0
        userMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        let messageConstraints = [
            userMessageLabel.leftAnchor.constraint(equalTo: userBubble.leftAnchor, constant: 16),
            userMessageLabel.topAnchor.constraint(equalTo: userBubble.topAnchor, constant: 10),
            userMessageLabel.rightAnchor.constraint(equalTo: userBubble.rightAnchor, constant: -16),
            userMessageLabel.bottomAnchor.constraint(equalTo: userBubble.bottomAnchor, constant: -10)]
        
        userBubble.addSubview(userMessageLabel)
        NSLayoutConstraint.activate(messageConstraints)
    }
    
    func setupFriendBubble() {
        friendThumbnailContainer.isHidden = true
        friendThumbnailContainer.layer.cornerRadius = 14
        friendThumbnailContainer.backgroundColor = .secondaryBackground
        friendThumbnailContainer.translatesAutoresizingMaskIntoConstraints = false
        let thumbnailConstraints = [
            friendThumbnailContainer.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 12),
            friendThumbnailContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            friendThumbnailContainer.heightAnchor.constraint(equalToConstant: 28),
            friendThumbnailContainer.widthAnchor.constraint(equalToConstant: 28)]
        
        contentView.addSubview(friendThumbnailContainer)
        NSLayoutConstraint.activate(thumbnailConstraints)
        
        // Thumbanail initial
        friendThumbnailLabel.font = .font(ofSize: 15, weight: .semibold)
        friendThumbnailLabel.textAlignment = .center
        friendThumbnailLabel.textColor = .primaryLightText
        friendThumbnailLabel.translatesAutoresizingMaskIntoConstraints = false
        let thumbnailLabelConstraints = [
            friendThumbnailLabel.centerXAnchor.constraint(equalTo: friendThumbnailContainer.centerXAnchor),
            friendThumbnailLabel.centerYAnchor.constraint(equalTo: friendThumbnailContainer.centerYAnchor)]
        
        friendThumbnailContainer.addSubview(friendThumbnailLabel)
        NSLayoutConstraint.activate(thumbnailLabelConstraints)
        
        // Thumbnail image
        friendThumbnailImage.layer.cornerRadius = 14
        friendThumbnailImage.contentMode = .scaleAspectFill
        friendThumbnailImage.layer.masksToBounds = true
        friendThumbnailImage.translatesAutoresizingMaskIntoConstraints = false
        let thumbnailImageConstraints = [
            friendThumbnailImage.leftAnchor.constraint(equalTo: friendThumbnailContainer.leftAnchor),
            friendThumbnailImage.topAnchor.constraint(equalTo: friendThumbnailContainer.topAnchor),
            friendThumbnailImage.rightAnchor.constraint(equalTo: friendThumbnailContainer.rightAnchor),
            friendThumbnailImage.bottomAnchor.constraint(equalTo: friendThumbnailContainer.bottomAnchor)]
        
        friendThumbnailContainer.addSubview(friendThumbnailImage)
        NSLayoutConstraint.activate(thumbnailImageConstraints)
        
        friendBubble.isHidden = true
        friendBubble.backgroundColor = .secondaryBackground
        friendBubble.layer.cornerRadius = 20
        friendBubble.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            friendBubble.leftAnchor.constraint(equalTo: friendThumbnailContainer.rightAnchor, constant: 6),
            friendBubble.topAnchor.constraint(equalTo: contentView.topAnchor),
            friendBubble.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor, constant: -60),
            friendBubble.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)]
        
        contentView.addSubview(friendBubble)
        NSLayoutConstraint.activate(constraints)
        
        friendMessageLabel.font = .font(ofSize: 17, weight: .medium)
        friendMessageLabel.textColor = .white
        friendMessageLabel.numberOfLines = 0
        friendMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        let messageConstraints = [
            friendMessageLabel.leftAnchor.constraint(equalTo: friendBubble.leftAnchor, constant: 16),
            friendMessageLabel.topAnchor.constraint(equalTo: friendBubble.topAnchor, constant: 10),
            friendMessageLabel.rightAnchor.constraint(equalTo: friendBubble.rightAnchor, constant: -16),
            friendMessageLabel.bottomAnchor.constraint(equalTo: friendBubble.bottomAnchor, constant: -10)]
        
        friendBubble.addSubview(friendMessageLabel)
        NSLayoutConstraint.activate(messageConstraints)
    }
}
