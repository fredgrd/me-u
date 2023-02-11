//
//  AddContactButton.swift
//  me&us
//
//  Created by Federico on 09/02/23.
//

import UIKit
import Combine

class AddContactButton: UIView {
    
    let onClick = PassthroughSubject<AddContactButton, Never>()
    
    var isEnabled: Bool = true
    
    var isSpinning: Bool = false
    
    // Subviews
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let activityIndicatorView = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        
        let longRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(sender:)))
        longRecognizer.minimumPressDuration = 0
        addGestureRecognizer(longRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func showSpinner() {
        isSpinning = true
        iconView.alpha = 0
        titleLabel.alpha = 0
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
    }
    
    func hideSpinner() {
        isSpinning = false
        iconView.alpha = 1
        titleLabel.alpha = 1
        activityIndicatorView.isHidden = true
        activityIndicatorView.stopAnimating()
    }
    
    @objc private func onLongPress(sender: UILongPressGestureRecognizer) {
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
private extension AddContactButton {
    func setupUI() {
        backgroundColor = .primaryHighlight
        
        setupIconView()
        setupTitleLabel()
        setupActivityIndicator()
    }
    
    func setupIconView() {
        iconView.image = UIImage(named: "plus@15pt")
        iconView.tintColor = .primaryDarkText
        iconView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            iconView.leftAnchor.constraint(equalTo: leftAnchor, constant: 14),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.heightAnchor.constraint(equalToConstant: 15),
            iconView.widthAnchor.constraint(equalToConstant: 15)]
        
        addSubview(iconView)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupTitleLabel() {
        titleLabel.font = .font(ofSize: 17, weight: .semibold)
        titleLabel.text = "Add"
        titleLabel.textColor = .primaryDarkText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            titleLabel.leftAnchor.constraint(equalTo: iconView.rightAnchor, constant: 6),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -14),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)]
        
        addSubview(titleLabel)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupActivityIndicator() {
        activityIndicatorView.tintColor = .primaryDarkText
        activityIndicatorView.isHidden = true
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            activityIndicatorView.topAnchor.constraint(equalTo: topAnchor),
            activityIndicatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor)]
        
        addSubview(activityIndicatorView)
        NSLayoutConstraint.activate(constraints)
    }
    
}
