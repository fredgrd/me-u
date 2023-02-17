//
//  CVCTypingIndicator.swift
//  me&us
//
//  Created by Federico on 15/02/23.
//

import UIKit

class CVCHeader: UIView {
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    private let titleLabel = UILabel()
    private var titleLabelTopConstraint = NSLayoutConstraint()
    private let typingLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showTyping(_ name: String) {
        typingLabel.text = "\(name) is typing..."
        titleLabelTopConstraint.constant = 6
        UIView.animate(withDuration: 0.2, delay: 0) {
            self.layoutIfNeeded()
        } completion: { _ in
            self.typingLabel.isHidden = false
        }
    }
    
    func hideTyping() {
        print("HIDE TYPING")
        titleLabelTopConstraint.constant = 12
        typingLabel.isHidden = true
        UIView.animate(withDuration: 0.2, delay: 0) {
            self.layoutIfNeeded()
        }
    }
}

// MARK: - UISetup
private extension CVCHeader {
    func setupUI() {
        setupTitleLabel()
        setupTypingLabel()
    }
    
    func setupTitleLabel() {
        titleLabel.font = .font(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .primaryLightText
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabelTopConstraint = titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12)
        let constraints = [
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            titleLabelTopConstraint,
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20)]
        
        addSubview(titleLabel)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupTypingLabel() {
        typingLabel.isHidden = true
        typingLabel.font = .font(ofSize: 13, weight: .medium)
        typingLabel.textColor = .secondaryLightText
        typingLabel.textAlignment = .center
        typingLabel.numberOfLines = 1
        typingLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            typingLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            typingLabel.centerXAnchor.constraint(equalTo: centerXAnchor)]
        
        addSubview(typingLabel)
        NSLayoutConstraint.activate(constraints)
    }
}
