//
//  IconButton.swift
//  me&us
//
//  Created by Federico on 04/02/23.
//

import UIKit
import Combine

class IconButton: UIView {
    
    let onClick = PassthroughSubject<UIGestureRecognizer.State, Never>()
    
    var isEnabled: Bool = true {
        didSet {
            alpha = isEnabled ? 1 : 0.2
        }
    }
    
    var image: UIImage? {
        didSet {
            iconView.image = image
        }
    }
    
    var sendAllEvents: Bool = false
    
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
        iconView.isHidden = true
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
    }
    
    func hideSpinner() {
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
        }
        
        if (sendAllEvents) {
            onClick.send(sender.state)
        } else if (sender.state == .ended) {
            onClick.send(.ended)
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
