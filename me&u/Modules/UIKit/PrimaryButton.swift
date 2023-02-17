//
//  PrimaryButton.swift
//  me&us
//
//  Created by Federico on 07/02/23.
//

import UIKit
import Combine

class PrimaryButton: UIView {
    let onClick = PassthroughSubject<PrimaryButton, Never>()
    
    var isEnabled: Bool = true {
        didSet {
            alpha = isEnabled ? 1 : 0.6
        }
    }
    
    var isSpinning: Bool = false
    
    var title: String = "Primary Button" {
        didSet {
            titleLabel.text = title
        }
    }
    
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
        isSpinning = true
        titleLabel.isHidden = true
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
    }
    
    func hideSpinner() {
        isSpinning = false
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
            onClick.send(self)
        }
    }
}

// MARK: - UISetup
private extension PrimaryButton {
    func setupUI() {
        backgroundColor = .primaryHighlight
        layer.cornerRadius = 22
        
        setupTitleLabel()
        setupActivityIndicatorView()
    }
    
    func setupTitleLabel() {
        titleLabel.font = .font(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .primaryDarkText
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 18),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -18),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)]
        
        addSubview(titleLabel)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupActivityIndicatorView() {
        activityIndicatorView.isHidden = true
        activityIndicatorView.color = .primaryDarkText
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        let constaints = [
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)]
        
        addSubview(activityIndicatorView)
        NSLayoutConstraint.activate(constaints)
    }
}
