//
//  DynamicLabel.swift
//  me&us
//
//  Created by Federico on 08/02/23.
//

import UIKit

class DynamicLabel: UIView {
    
    private let staticText: String
    
    private var staticLabelRxConstraint = NSLayoutConstraint()
    
    // Subviews
    private let staticLabel = UILabel()
    private let dynamicLabel = UILabel()
    
    required init(staticText: String) {
        self.staticText = staticText
        super.init(frame: .zero)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDynamicText(_ text: String) {
        dynamicLabel.text = text
        let size = (text as NSString).boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: staticLabel.frame.height), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.font(ofSize: 17, weight: .bold)], context: nil)
        staticLabelRxConstraint.constant = -ceil(size.width)
    }
    
    func animateChange(withText text: String) {
        let size = (text as NSString).boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: staticLabel.frame.height), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.font(ofSize: 17, weight: .bold)], context: nil)
        
        UIView.animate(withDuration: 0.2, delay: 0) {
            self.dynamicLabel.alpha = 0
        } completion: { _ in
            self.dynamicLabel.text = text
        }
        dynamicLabel.alpha = 0
        
        self.staticLabelRxConstraint.constant = -ceil(size.width)
        UIView.animate(withDuration: 0.5, delay: 0.2) {
            self.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.7) {
            self.dynamicLabel.alpha = 1
        }
    }
}

// MARK: - UISetup
private extension DynamicLabel {
    func setupUI() {
        setupStaticLabel()
        setupDynamicLabel()
    }
    
    func setupStaticLabel() {
        staticLabel.font = .font(ofSize: 17, weight: .bold)
        staticLabel.textColor = .primaryText
        staticLabel.text = staticText
        staticLabel.translatesAutoresizingMaskIntoConstraints = false
        staticLabelRxConstraint = staticLabel.rightAnchor.constraint(equalTo: rightAnchor)
        let constraints = [
            staticLabel.leftAnchor.constraint(equalTo: leftAnchor),
            staticLabel.topAnchor.constraint(equalTo: topAnchor),
            staticLabelRxConstraint,
            staticLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        
        addSubview(staticLabel)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupDynamicLabel() {
        dynamicLabel.font = .font(ofSize: 17, weight: .bold)
        dynamicLabel.textColor = .primaryHighlight
        dynamicLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            dynamicLabel.topAnchor.constraint(equalTo: topAnchor),
            dynamicLabel.rightAnchor.constraint(equalTo: rightAnchor),
            dynamicLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        
        addSubview(dynamicLabel)
        NSLayoutConstraint.activate(constraints)
    }
}
