//
//  FVCContactCell.swift
//  me&us
//
//  Created by Federico on 09/02/23.
//

import UIKit

class FVCContactCell: UICollectionViewCell {
    static let identifier = "FVCContactCell"

    private var number: String?
    
    private let thumbnailContainer = UIView()
    private let thumbnailInitialLabel = UILabel()
    private let thumbnailImageView = UIImageView()
    
    private let detailsContainer = UIView()
    private let nameLabel = UILabel()
    private let numberLabel = UILabel()
    
    let addButton = AddContactButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(withContact contact: Contact) {
        self.number = contact.number
        
        // Image setup
        if let imageData = contact.imagedata {
            thumbnailImageView.image = UIImage(data: imageData)
            thumbnailInitialLabel.isHidden = true
            thumbnailImageView.isHidden = false
        } else {
            thumbnailInitialLabel.text = contact.name.first?.uppercased()
            thumbnailImageView.isHidden = true
            thumbnailInitialLabel.isHidden = false
        }
        
        // Name and number
        nameLabel.text = "\(contact.name) \(contact.surname)"
        numberLabel.text = contact.is_user ? "Already on me&u 💛" : contact.number
    }
}

// MARK: - UISetup
private extension FVCContactCell {
    func setupUI() {
        backgroundColor = .primaryBackground

        setupThumbnail()
        setupDetails()
        setupAddButton()
    }
    
    func setupThumbnail() {
        thumbnailContainer.translatesAutoresizingMaskIntoConstraints = false
        let thumbnailContainerConstraints = [
            thumbnailContainer.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            thumbnailContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbnailContainer.heightAnchor.constraint(equalToConstant: 55),
            thumbnailContainer.widthAnchor.constraint(equalToConstant: 55)]
        
        contentView.addSubview(thumbnailContainer)
        NSLayoutConstraint.activate(thumbnailContainerConstraints)
        
        let background = UIImageView()
        background.image = UIImage(named: "contact-thumbnail-container@55pt")
        background.translatesAutoresizingMaskIntoConstraints = false
        let backgroundConstraints = [
            background.leftAnchor.constraint(equalTo: thumbnailContainer.leftAnchor),
            background.topAnchor.constraint(equalTo: thumbnailContainer.topAnchor),
            background.rightAnchor.constraint(equalTo: thumbnailContainer.rightAnchor),
            background.bottomAnchor.constraint(equalTo: thumbnailContainer.bottomAnchor)]
        
        thumbnailContainer.addSubview(background)
        NSLayoutConstraint.activate(backgroundConstraints)
        
        thumbnailInitialLabel.font = .font(ofSize: 21, weight: .semibold)
        thumbnailInitialLabel.textColor = .primaryText
        thumbnailInitialLabel.textAlignment = .center
        thumbnailInitialLabel.isHidden = true
        thumbnailInitialLabel.translatesAutoresizingMaskIntoConstraints = false
        let labelConstraints = [
            thumbnailInitialLabel.centerYAnchor.constraint(equalTo: thumbnailContainer.centerYAnchor),
            thumbnailInitialLabel.centerXAnchor.constraint(equalTo: thumbnailContainer.centerXAnchor)]
        
        thumbnailContainer.addSubview(thumbnailInitialLabel)
        NSLayoutConstraint.activate(labelConstraints)
        
        thumbnailImageView.layer.cornerRadius = 22.5
        thumbnailImageView.layer.masksToBounds = true
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.isHidden = true
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        let imageConstraints = [
            thumbnailImageView.centerYAnchor.constraint(equalTo: thumbnailContainer.centerYAnchor),
            thumbnailImageView.centerXAnchor.constraint(equalTo: thumbnailContainer.centerXAnchor),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 45),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 45)]
        
        thumbnailContainer.addSubview(thumbnailImageView)
        NSLayoutConstraint.activate(imageConstraints)
    }
    
    func setupDetails() {
        detailsContainer.translatesAutoresizingMaskIntoConstraints = false
        let detailsConstraints = [
            detailsContainer.leftAnchor.constraint(equalTo: thumbnailContainer.rightAnchor, constant: 12),
            detailsContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)]
        
        contentView.addSubview(detailsContainer)
        NSLayoutConstraint.activate(detailsConstraints)
        
        nameLabel.font = .font(ofSize: 17, weight: .semibold)
        nameLabel.textColor = .primaryLightText
        nameLabel.numberOfLines = 1
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        let nameConstraints = [
            nameLabel.leftAnchor.constraint(equalTo: detailsContainer.leftAnchor),
            nameLabel.topAnchor.constraint(equalTo: detailsContainer.topAnchor),
            nameLabel.rightAnchor.constraint(equalTo: detailsContainer.rightAnchor)]
        
        detailsContainer.addSubview(nameLabel)
        NSLayoutConstraint.activate(nameConstraints)
        
        numberLabel.font = .font(ofSize: 15, weight: .medium)
        numberLabel.textColor = .secondaryText
        numberLabel.numberOfLines = 1
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        let numberConstraints = [
            numberLabel.leftAnchor.constraint(equalTo: detailsContainer.leftAnchor),
            numberLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            numberLabel.rightAnchor.constraint(equalTo: detailsContainer.rightAnchor),
            numberLabel.bottomAnchor.constraint(equalTo: detailsContainer.bottomAnchor)]
        
        detailsContainer.addSubview(numberLabel)
        NSLayoutConstraint.activate(numberConstraints)
    }
    
    func setupAddButton() {
        addButton.layer.cornerRadius = 18
        addButton.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            addButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            addButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            addButton.heightAnchor.constraint(equalToConstant: 36)]
        
        contentView.addSubview(addButton)
        NSLayoutConstraint.activate(constraints)
    }
}
