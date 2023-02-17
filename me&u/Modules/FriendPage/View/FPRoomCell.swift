//
//  FPRoomCell.swift
//  me&us
//
//  Created by Federico on 16/02/23.
//

import UIKit

class FPRoomCell: UICollectionViewCell {
    static let identifier = "FPRoomCell"
    
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(title: String, description: String) {
        self.titleLabel.text = title
        self.descriptionLabel.text = description
    }
}

// MARK: - UISetup
private extension FPRoomCell {
    func setupUI() {
        contentView.backgroundColor = .secondaryBackground
        contentView.layer.cornerRadius = 17
    
        setupTitleLabel()
        setupDescriptionLabel()
    }
    
    func setupTitleLabel() {
        titleLabel.font = .font(ofSize: 17, weight: .semibold)
        titleLabel.textColor =  .primaryLightText
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 28),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 28)]
        
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupDescriptionLabel() {
        descriptionLabel.font = .font(ofSize: 15, weight: .semibold)
        descriptionLabel.textColor =  .primaryLightText
        descriptionLabel.numberOfLines = 4
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            descriptionLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 28),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            descriptionLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -28),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)]
        
        contentView.addSubview(descriptionLabel)
        NSLayoutConstraint.activate(constraints)
    }
}
