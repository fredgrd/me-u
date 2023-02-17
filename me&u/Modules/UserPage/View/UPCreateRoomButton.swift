//
//  UPCreateRoomButton.swift
//  me&us
//
//  Created by Federico on 15/02/23.
//

import UIKit
import Combine

class UPCreateRoomButton: UIView {
    let onClick = PassthroughSubject<UPCreateRoomButton, Never>()
    
    var isSpinning: Bool = false

    // Subviews
    private let iconImage = UIImageView()
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
private extension UPCreateRoomButton {
    func setupUI() {
        backgroundColor = .init(hex: "#55BB70")
        layer.cornerRadius = 22
        
        setupIconImage()
        setupTitleLabel()
    }
    
    func setupIconImage() {
        iconImage.image = UIImage(named: "plus@15pt")
        iconImage.tintColor = .white
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            iconImage.leftAnchor.constraint(equalTo: leftAnchor, constant: 18),
            iconImage.heightAnchor.constraint(equalToConstant: 15),
            iconImage.widthAnchor.constraint(equalToConstant: 15),
            iconImage.centerYAnchor.constraint(equalTo: centerYAnchor)]
        
        addSubview(iconImage)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupTitleLabel() {
        titleLabel.text = "Room"
        titleLabel.font = .font(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            titleLabel.leftAnchor.constraint(equalTo: iconImage.rightAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -18),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)]
        
        addSubview(titleLabel)
        NSLayoutConstraint.activate(constraints)
    }
}
