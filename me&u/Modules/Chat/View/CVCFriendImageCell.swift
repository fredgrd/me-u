//
//  CVCFriendImageCell.swift
//  me&u
//
//  Created by Federico on 21/02/23.
//

import UIKit

class CVCFriendImageCell: UICollectionViewCell {
    static let identifier = "CVCFriendImageCell"
    
    // Actions
    var imageOnTap: ((_ cell: CVCFriendImageCell, _ frame: CGRect) -> Void)?
    
    // Subviews
    private let avatarView = UIView()
    private let avatarLabel = UILabel()
    private let avatarImage = UIImageView()
    
    private let bubbleView = UIView()
    private let bubbleImage = UIImageView()
    
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        bubbleView.addGestureRecognizer(tapRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ imageUrl: String, userName: String, avatarUrl: String, showAvatar: Bool) {
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
       
        imageView.sd_setImage(with: URL(string: imageUrl))
    }
    
    @objc private func onTap() {
        guard let imageOnTap = imageOnTap else {
            return
        }
        
        var frame = imageView.frame
        frame.origin = bubbleView.convert(imageView.frame.origin, to: self)
        
        imageOnTap(self, frame)
    }
}

// MARK: - UISetup
private extension CVCFriendImageCell {
    func setupUI() {
        setupAvatar()
        setupBubble()
        setupBubbleImage()
        setupImageView()
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
    
    func setupImageView() {
        imageView.layer.cornerRadius = 18
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            imageView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 3),
            imageView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -3),
            imageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -3),
            imageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 7)]
        
        bubbleView.addSubview(imageView)
        NSLayoutConstraint.activate(constraints)
    }
}
