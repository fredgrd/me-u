//
//  CVCFriendTextCell.swift
//  me&u
//
//  Created by Federico on 21/02/23.
//

import UIKit

class CVCFriendTextCell: UICollectionViewCell {
    static let identifier = "CVCFriendTextCell"
    
    // Subviews
    private let avatarView = UIView()
    private let avatarLabel = UILabel()
    private let avatarImage = UIImageView()
    private let bubbleView = UIView()
    private let bubbleImage = UIImageView()
    private let messageLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ text: String, userName: String, avatarUrl: String, showAvatar: Bool) {
        if showAvatar {
            bubbleImage.image = UIImage(named: "chat-bubble-lx@40pt")?.resizableImage(withCapInsets: UIEdgeInsets(top: 20, left: 24, bottom: 20, right: 24), resizingMode: .stretch)
            
            avatarView.isHidden = false
            
            if avatarUrl == "none" {
                avatarImage.isHidden = true
                avatarLabel.isHidden = false
                avatarLabel.text = userName.first?.uppercased()
            } else {
                avatarImage.isHidden = false
                avatarLabel.isHidden = true
                avatarImage.sd_setImage(with: URL(string: avatarUrl))
            }
        } else {
            bubbleImage.image = UIImage(named: "chat-bubble-lx-notail@40pt")?.resizableImage(withCapInsets: UIEdgeInsets(top: 20, left: 24, bottom: 20, right: 24), resizingMode: .stretch)
            
            avatarView.isHidden = true
        }
       
        messageLabel.text = text
    }
}

// MARK: - UISetup
private extension CVCFriendTextCell {
    func setupUI() {
        setupAvatar()
        setupBubble()
        setupBubbleImage()
        setupMessageLabel()
    }
    
    func setupAvatar() {
        avatarView.isHidden = true
        avatarView.layer.cornerRadius = 14
        avatarView.backgroundColor = .secondaryBackground
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        let viewConstraints = [
            avatarView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            avatarView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 12),
            avatarView.heightAnchor.constraint(equalToConstant: 28),
            avatarView.widthAnchor.constraint(equalToConstant: 28)]
        
        contentView.addSubview(avatarView)
        NSLayoutConstraint.activate(viewConstraints)
        
        // Label
        avatarLabel.isHidden = true
        avatarLabel.font = .font(ofSize: 13, weight: .bold)
        avatarLabel.textColor = .primaryLightText
        avatarLabel.textAlignment = .center
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        let labelConstraints = [
            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor)]
        
        avatarView.addSubview(avatarLabel)
        NSLayoutConstraint.activate(labelConstraints)
        
        // Image
        avatarImage.isHidden = true
        avatarImage.layer.masksToBounds = true
        avatarImage.layer.cornerRadius = 14
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        let imageConstraints = [
            avatarImage.topAnchor.constraint(equalTo: avatarView.topAnchor),
            avatarImage.rightAnchor.constraint(equalTo: avatarView.rightAnchor),
            avatarImage.bottomAnchor.constraint(equalTo: avatarView.bottomAnchor),
            avatarImage.leftAnchor.constraint(equalTo: avatarView.leftAnchor)]
        
        avatarView.addSubview(avatarImage)
        NSLayoutConstraint.activate(imageConstraints)
    }
    
    func setupBubble() {
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bubbleView.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor, constant: -60),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bubbleView.leftAnchor.constraint(equalTo: avatarView.rightAnchor, constant: 6)]
        
        contentView.addSubview(bubbleView)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupBubbleImage() {
        bubbleImage.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            bubbleImage.topAnchor.constraint(equalTo: bubbleView.topAnchor),
            bubbleImage.rightAnchor.constraint(equalTo: bubbleView.rightAnchor),
            bubbleImage.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
            bubbleImage.leftAnchor.constraint(equalTo: bubbleView.leftAnchor)]
        
        bubbleView.addSubview(bubbleImage)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupMessageLabel() {
        messageLabel.font = .font(ofSize: 16, weight: .regular)
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor),
            messageLabel.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -20),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
            messageLabel.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 24)]
        
        bubbleView.addSubview(messageLabel)
        NSLayoutConstraint.activate(constraints)
    }
}
