//
//  CVCUserTextCell.swift
//  me&u
//
//  Created by Federico on 21/02/23.
//

import UIKit

class CVCUserTextCell: UICollectionViewCell {
    static let identifier = "CVCUserTextCell"
    
    // Subviews
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
    
    func update(_ text: String, showAvatar: Bool) {
        if showAvatar {
            bubbleImage.image = UIImage(named: "chat-bubble-rx@40pt")?.resizableImage(withCapInsets: UIEdgeInsets(top: 20, left: 24, bottom: 20, right: 24), resizingMode: .stretch)
        } else {
            bubbleImage.image = UIImage(named: "chat-bubble-rx-notail@40pt")?.resizableImage(withCapInsets: UIEdgeInsets(top: 20, left: 24, bottom: 20, right: 24), resizingMode: .stretch)
        }
       
        messageLabel.text = text
    }
}

// MARK: - UISetup
private extension CVCUserTextCell {
    func setupUI() {
        setupBubble()
        setupBubbleImage()
        setupMessageLabel()
    }
    
    func setupBubble() {
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bubbleView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -12),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bubbleView.leftAnchor.constraint(greaterThanOrEqualTo: contentView.leftAnchor, constant: 60)]
        
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
            messageLabel.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -24),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
            messageLabel.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 20)]
        
        bubbleView.addSubview(messageLabel)
        NSLayoutConstraint.activate(constraints)
    }
}
