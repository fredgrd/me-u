//
//  CVCDescriptionCell.swift
//  me&us
//
//  Created by Federico on 13/02/23.
//

import UIKit

class CVCDescriptionCell: UICollectionViewCell {
    static let identifier = "CVCDescriptionCell"
    
    private let descritpionLabel = UILabel()
     
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(withDescription description: String) {
        descritpionLabel.text = description
    }
}

// MARK: - UISetup
private extension CVCDescriptionCell {
    func setupUI() {
        setupDescriptionCard()
    }
    
    func setupDescriptionCard() {
        let card = UIView()
        card.backgroundColor = .secondaryBackground
        card.layer.cornerRadius = 17
        card.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            card.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            card.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)]
        
        contentView.addSubview(card)
        NSLayoutConstraint.activate(constraints)
        
        descritpionLabel.font = .font(ofSize: 17, weight: .medium)
        descritpionLabel.textColor = .primaryLightText
        descritpionLabel.numberOfLines = 0
        descritpionLabel.translatesAutoresizingMaskIntoConstraints = false
        let descriptionConstraints = [
            descritpionLabel.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 20),
            descritpionLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            descritpionLabel.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -20),
            descritpionLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)]
        
        contentView.addSubview(descritpionLabel)
        NSLayoutConstraint.activate(descriptionConstraints)
    }
}
