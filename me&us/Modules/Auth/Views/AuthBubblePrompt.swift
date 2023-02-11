//
//  AuthBubblePrompt.swift
//  me&us
//
//  Created by Federico on 04/02/23.
//

import UIKit

class AuthBubblePrompt: UIView {
    
    let message: String
    
    required init(message: String) {
        self.message = message
        super.init(frame: .zero)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UISetup
private extension AuthBubblePrompt {
    func setupUI() {
        setupBubble()
        setupMessageLabel()
    }
    
    func setupBubble() {
        let bubbleImage = UIImageView()
        bubbleImage.image = UIImage(named: "auth-bubble-left@60pt")?.resizableImage(withCapInsets: UIEdgeInsets(top: 30, left: 38, bottom: 30, right: 38), resizingMode: .stretch)
        bubbleImage.translatesAutoresizingMaskIntoConstraints = false
        let bubbleConstraints = [
            bubbleImage.leftAnchor.constraint(equalTo: self.leftAnchor),
            bubbleImage.topAnchor.constraint(equalTo: self.topAnchor),
            bubbleImage.rightAnchor.constraint(equalTo: self.rightAnchor),
            bubbleImage.bottomAnchor.constraint(equalTo: self.bottomAnchor)]
        
        addSubview(bubbleImage)
        NSLayoutConstraint.activate(bubbleConstraints)
    }
    
    func setupMessageLabel() {
        let messageLabel = UILabel()
        messageLabel.font = .font(ofSize: 21, weight: .semibold)
        messageLabel.textColor = .white
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            messageLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 38),
            messageLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -30),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor)]
        
        addSubview(messageLabel)
        NSLayoutConstraint.activate(constraints)
    }
    
}
