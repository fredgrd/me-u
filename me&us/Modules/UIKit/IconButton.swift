//
//  IconButton.swift
//  me&us
//
//  Created by Federico on 04/02/23.
//

import UIKit
import Combine

class IconButton: UIView {
    
    let onClick = PassthroughSubject<IconButton, Never>()
    
    var isEnabled: Bool = true {
        didSet {
            alpha = isEnabled ? 1 : 0.2
        }
    }
    
    var isSpinning: Bool = false
    
    var image: UIImage? {
        didSet {
            iconView.image = image
        }
    }
    
    var imageTintColor: UIColor? {
        didSet{
            iconView.tintColor = imageTintColor
        }
    }
    
    // Subviews
    private let iconView = UIImageView()
    private let activityIndicatorView = UIActivityIndicatorView()
    
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
    
    func showSpinner() {
        isSpinning = true
        iconView.isHidden = true
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
    }
    
    func hideSpinner() {
        isSpinning = false
        iconView.isHidden = false
        activityIndicatorView.isHidden = true
        activityIndicatorView.stopAnimating()
    }

    @objc private func onClick(sender: UILongPressGestureRecognizer) {
        if (!isEnabled) {
            return
        }
        
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
private extension IconButton {
    func setupUI() {
        setupIconView()
        setupActivityIndicatorView()
    }
    
    func setupIconView() {
        iconView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor)]
        
        addSubview(iconView)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupActivityIndicatorView() {
        activityIndicatorView.isHidden = true
        activityIndicatorView.color = .primaryLightText
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        let constaints = [
            activityIndicatorView.leftAnchor.constraint(equalTo: leftAnchor),
            activityIndicatorView.topAnchor.constraint(equalTo: topAnchor),
            activityIndicatorView.rightAnchor.constraint(equalTo: rightAnchor),
            activityIndicatorView.bottomAnchor.constraint(equalTo: bottomAnchor)]
        
        addSubview(activityIndicatorView)
        NSLayoutConstraint.activate(constaints)
    }
}
