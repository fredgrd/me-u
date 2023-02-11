//
//  FVCSectionHeader.swift
//  me&us
//
//  Created by Federico on 10/02/23.
//

import UIKit

class FVCSectionHeader: UICollectionReusableView {
    static let identifier = "FVCSectionHeader"
    
    // Subviews
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(withTitle title: String, icon: UIImage?) {
        titleLabel.text = title
        iconView.image = icon
        iconView.tintColor = .primaryText
    }
}

// MARK: - UISetup
private extension FVCSectionHeader {
    func setupUI() {
        backgroundColor = .primaryBackground
        
        setupIconView()
        setupTitleLabel()
    }
    
    func setupIconView() {
        iconView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            iconView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.heightAnchor.constraint(equalToConstant: 22),
            iconView.widthAnchor.constraint(equalToConstant: 22)]
        
        addSubview(iconView)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupTitleLabel() {
        titleLabel.font = UIFont.font(ofSize: 17, weight: .bold)
        titleLabel.textColor = .primaryLightText
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            titleLabel.leftAnchor.constraint(equalTo: iconView.rightAnchor, constant: 6),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)]
        
        addSubview(titleLabel)
        NSLayoutConstraint.activate(constraints)
    }
}
