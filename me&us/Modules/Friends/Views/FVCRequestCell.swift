//
//  FVCRequestCell.swift
//  me&us
//
//  Created by Federico on 11/02/23.
//

import UIKit
import Combine

class FVCRequestCell: UICollectionViewCell {
    static let identifier = "FVCRequestCell"
    
    enum Kind {
        case received
        case sent
    }
    
    private var kind: Kind?
    
    private var bag = Set<AnyCancellable>()
    
    var acceptAction: ((_ button: IconButton) -> Void)?
    var cancelAction: ((_ button: IconButton) -> Void)?
    
    // Subviews
    private let thumbnailContainer = UIView()
    private let thumbnailInitialLabel = UILabel()
    private let thumbnailImageView = UIImageView()
    
    private let detailsContainer = UIView()
    private let nameLabel = UILabel()
    private let numberLabel = UILabel()
    
    private let acceptButton = IconButton()
    private let cancelButton = IconButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bindUI() {
        acceptButton.onClick.receive(on: DispatchQueue.main).sink { button in
            guard let acceptAction = self.acceptAction else {
                return
            }
            
            acceptAction(button)
        }.store(in: &bag)
        
        cancelButton.onClick.receive(on: DispatchQueue.main).sink { button in
            guard let cancelAction = self.cancelAction else {
                return
            }
            
            cancelAction(button)
        }.store(in: &bag)
    }
    
    func update(_ request: FriendRequest, kind: Kind) {
        self.kind = kind
        
        // Image setup
        if (kind == .received ? request.from_user.avatar_url : request.to_user.avatar_url) != "none" {
            thumbnailImageView.sd_setImage(with: URL(string: kind == .received ? request.from_user.avatar_url : request.to_user.avatar_url))
            thumbnailInitialLabel.isHidden = true
            thumbnailImageView.isHidden = false
        } else {
            thumbnailInitialLabel.text = (kind == .received ? request.from_user.name : request.to_user.name).first?.uppercased()
            thumbnailImageView.isHidden = true
            thumbnailInitialLabel.isHidden = false
        }
       
        // Name and number
        nameLabel.text = kind == .received ? request.from_user.name : request.to_user.name
        numberLabel.text = kind == .received ? request.from : request.to
        
        // Buttons
        acceptButton.isEnabled = kind == .received
        acceptButton.alpha = kind == .received ? 1 : 0
        cancelButton.image = kind == .received ? UIImage(named: "close@38pt") : UIImage(named: "close-circle@38pt")
    }
}

// MARK: - UISetup
private extension FVCRequestCell {
    func setupUI() {
        backgroundColor = .primaryBackground

        setupThumbnail()
        setupDetails()
        setupButtons()
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
        thumbnailInitialLabel.textColor = .primaryLightText
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
        numberLabel.textColor = .secondaryLightText
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
    
    func setupButtons() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            stack.leftAnchor.constraint(equalTo: detailsContainer.rightAnchor, constant: 16),
            stack.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stack.heightAnchor.constraint(equalToConstant: 38),
            stack.widthAnchor.constraint(equalToConstant: 82)]
        
        contentView.addSubview(stack)
        NSLayoutConstraint.activate(constraints)
        
        acceptButton.image = UIImage(named: "accept-circle@38pt")
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        let acceptBtnConstraints = [
            acceptButton.heightAnchor.constraint(equalToConstant: 38),
            acceptButton.widthAnchor.constraint(equalToConstant: 38)]
        
        stack.addArrangedSubview(acceptButton)
        NSLayoutConstraint.activate(acceptBtnConstraints)
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        let cancelBtnConstraints = [
            cancelButton.heightAnchor.constraint(equalToConstant: 38),
            cancelButton.widthAnchor.constraint(equalToConstant: 38)]
        
        stack.addArrangedSubview(cancelButton)
        NSLayoutConstraint.activate(cancelBtnConstraints)
    }
}
