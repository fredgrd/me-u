//
//  PVCSettingButton.swift
//  me&us
//
//  Created by Federico on 17/02/23.
//

import UIKit
import Combine

class PVCSettingButton: UIView {
    
    let onClick = PassthroughSubject<PVCSettingButton, Never>()
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var image: UIImage? {
        didSet {
            iconView.image = image
        }
    }
    
    // Subviews
    private let iconContainer = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onTap(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            alpha = 0.8
        }
        
        if sender.state == .ended {
            alpha = 1
            onClick.send(self)
        }
    }
}

// MARK: - UISetup
private extension PVCSettingButton {
    func setupUI() {
        setupIcon()
        setupTitle()
        setupArrow()
        
        let longRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onTap(sender:)))
        longRecognizer.minimumPressDuration = 0
        addGestureRecognizer(longRecognizer)
    }
    
    func setupIcon() {
        iconContainer.backgroundColor = .primaryBackground
        iconContainer.layer.cornerRadius = 20
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        let containerConstraints = [
            iconContainer.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            iconContainer.heightAnchor.constraint(equalToConstant: 40),
            iconContainer.widthAnchor.constraint(equalToConstant: 40),
            iconContainer.centerYAnchor.constraint(equalTo: centerYAnchor)]
        
        addSubview(iconContainer)
        NSLayoutConstraint.activate(containerConstraints)
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        let iconConstraints = [
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor)]
        
        iconContainer.addSubview(iconView)
        NSLayoutConstraint.activate(iconConstraints)
    }
    
    private func setupTitle() {
        titleLabel.font = .font(ofSize: 17, weight: .semibold)
        titleLabel.numberOfLines = 1
        titleLabel.textColor = .primaryLightText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let titleConstraints = [
            titleLabel.leftAnchor.constraint(equalTo: iconContainer.rightAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)]
        
        addSubview(titleLabel)
        NSLayoutConstraint.activate(titleConstraints)
    }
    
    private func setupArrow() {
        let arrow = UIImageView()
        arrow.image = UIImage(named: "arrow-rx@24pt")
        arrow.tintColor = .primaryLightText
        arrow.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            arrow.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            arrow.centerYAnchor.constraint(equalTo: centerYAnchor),
            arrow.heightAnchor.constraint(equalToConstant: 24),
            arrow.widthAnchor.constraint(equalToConstant: 24)]
        
        addSubview(arrow)
        NSLayoutConstraint.activate(constraints)
    }
}
