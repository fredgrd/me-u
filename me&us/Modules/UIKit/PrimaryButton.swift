//
//  PrimaryButton.swift
//  me&us
//
//  Created by Federico on 07/02/23.
//

import UIKit
import Combine

class PrimaryButton: UIView {
    let onClick = PassthroughSubject<UIGestureRecognizer.State, Never>()
    
    var isEnabled: Bool = true {
        didSet {
            alpha = isEnabled ? 1 : 0.6
        }
    }
    
    var title: String = "Primary Button" {
        didSet {
            titleLabel.text = title
        }
    }

    var sendAllEvents: Bool = false
    
    // Subviews
    private let titleLabel = UILabel()
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
        titleLabel.isHidden = true
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
    }
    
    func hideSpinner() {
        titleLabel.isHidden = false
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
private extension PrimaryButton {
    func setupUI() {
        backgroundColor = .lightSalmon
        
        setupTitleLabel()
        setupActivityIndicatorView()
    }
    
    func setupTitleLabel() {
        titleLabel.font = .font(ofSize: 21, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 35),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -35),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)]
        
        addSubview(titleLabel)
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
