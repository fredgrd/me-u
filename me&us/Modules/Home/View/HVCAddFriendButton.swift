//
//  HVCAddFriendButton.swift
//  me&us
//
//  Created by Federico on 12/02/23.
//

import UIKit
import Combine

class HVCAddFriendButton : UIView {
    
    let onClick = PassthroughSubject<HVCAddFriendButton
 , Never>()
    
    // Subviews
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onClick(sender: )))
        longPressGesture.minimumPressDuration = 0
        addGestureRecognizer(longPressGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func onClick(sender: UILongPressGestureRecognizer) {
        if (sender.state == .began) {
            alpha = 0.8
        }
        
        if (sender.state == .ended) {
            alpha = 1
            onClick.send(self)
        }
    }
}

// MARK: - UISetup
private extension HVCAddFriendButton {
    func setupUI() {
        setupIconView()
        setupTitleLabel()
    }
    
    func setupIconView() {
        iconView.image = UIImage(named: "users@16pt")
        iconView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            iconView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.heightAnchor.constraint(equalToConstant: 16),
            iconView.widthAnchor.constraint(equalToConstant: 18)]
        
        addSubview(iconView)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupTitleLabel() {
        titleLabel.text = "Add a friend"
        titleLabel.font = .font(ofSize: 17, weight: .bold)
        titleLabel.textColor = .primaryLightText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            titleLabel.leftAnchor.constraint(equalTo: iconView.rightAnchor, constant: 6),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        
        addSubview(titleLabel)
        NSLayoutConstraint.activate(constraints)
    }
}
