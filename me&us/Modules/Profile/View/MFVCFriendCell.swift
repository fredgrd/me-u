//
//  MFVCFriendCell.swift
//  me&us
//
//  Created by Federico on 17/02/23.
//

import UIKit
import Combine

class MFVCFriendCell: UICollectionViewCell {
    static let identifier = "MFVCFriendCell"
    
    var deleteAction: (() -> Void)?
    
    private var bag = Set<AnyCancellable>()
    
    private let avatarView = UIView()
    private let avatarImageView = UIImageView()
    private let avatarInitialLabel = UILabel()
    
    private let nameLabel = UILabel()
    
    private let deleteButton = IconButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarInitialLabel.isHidden = true
        avatarImageView.isHidden = true
    }
    
    func update(withDetails details: UserFriendDetails) {
        if details.avatar_url == "none" {
            avatarInitialLabel.isHidden = false
            avatarInitialLabel.text = details.name.first?.uppercased() ?? ""
        } else {
            avatarImageView.isHidden = false
            avatarImageView.sd_setImage(with: URL(string: details.avatar_url))
        }
        
        nameLabel.text = details.name
    }
    
    private func bindUI() {
        deleteButton.onClick.receive(on: RunLoop.main).sink { _ in
            guard let deleteAction = self.deleteAction else {
                return
            }
            
            deleteAction()
        }.store(in: &bag)
    }
}

// MARK: - UISetup
private extension MFVCFriendCell {
    func setupUI() {
        setupAvatar()
        setupNameLabel()
        setupDeleteButton()
    }
    
    func setupAvatar() {
        avatarView.layer.cornerRadius = 10
        avatarView.backgroundColor = .primaryBackground
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        let viewConstraints = [
            avatarView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            avatarView.heightAnchor.constraint(equalToConstant: 40),
            avatarView.widthAnchor.constraint(equalToConstant: 40),
            avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)]
        
        contentView.addSubview(avatarView)
        NSLayoutConstraint.activate(viewConstraints)
        
        avatarInitialLabel.isHidden = true
        avatarInitialLabel.font = .font(ofSize: 21, weight: .semibold)
        avatarInitialLabel.textColor = .primaryLightText
        avatarInitialLabel.translatesAutoresizingMaskIntoConstraints = false
        let initialConstraints = [
            avatarInitialLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            avatarInitialLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor)]
        
        avatarView.addSubview(avatarInitialLabel)
        NSLayoutConstraint.activate(initialConstraints)
        
        
        avatarImageView.isHidden = true
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = 10
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        let imageConstraints = [
            avatarImageView.topAnchor.constraint(equalTo: avatarView.topAnchor),
            avatarImageView.rightAnchor.constraint(equalTo: avatarView.rightAnchor),
            avatarImageView.bottomAnchor.constraint(equalTo: avatarView.bottomAnchor),
            avatarImageView.leftAnchor.constraint(equalTo: avatarView.leftAnchor)]
        
        avatarView.addSubview(avatarImageView)
        NSLayoutConstraint.activate(imageConstraints)
        
    }
    
    func setupNameLabel() {
        nameLabel.font = .font(ofSize: 17, weight: .semibold)
        nameLabel.textColor = .primaryLightText
        nameLabel.numberOfLines = 1
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        let nameConstraints = [
            nameLabel.leftAnchor.constraint(equalTo: avatarView.rightAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)]
        
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate(nameConstraints)
    }
    
    func setupDeleteButton() {
        deleteButton.image = UIImage(named: "trash@18pt")
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            deleteButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
            deleteButton.leftAnchor.constraint(equalTo: nameLabel.rightAnchor, constant: 12),
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteButton.heightAnchor.constraint(equalToConstant: 24),
            deleteButton.widthAnchor.constraint(equalToConstant: 24)]
        
        contentView.addSubview(deleteButton)
        NSLayoutConstraint.activate(constraints)
    }
}
