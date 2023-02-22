//
//  UPRoomCell.swift
//  me&us
//
//  Created by Federico on 12/02/23.
//

import UIKit
import Combine

class UPRoomCell: UICollectionViewCell {
    static let identifier = "UPRoomCell"
    
    var dotsAction: (() -> Void)?
    
    var notificationsCount: Int = 0 {
        didSet {
            print("NOTIFICATIONS!!!", notificationsCount)
            unreadCountView.isHidden = notificationsCount == 0
            unreadCountLabel.text = String(notificationsCount)
        }
    }
    
    private var bag = Set<AnyCancellable>()
    
    private let dotsButton = IconButton()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let unreadCountView = UIView()
    private let unreadCountLabel = UILabel()
    
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
        unreadCountView.isHidden = true
    }
    
    private func bindUI() {
        dotsButton.onClick.receive(on: DispatchQueue.main).sink { button in
            guard let dotsAction = self.dotsAction else {
                return
            }
            
            dotsAction()
        }.store(in: &bag)
    }
    
    func update(title: String, description: String) {
        self.titleLabel.text = title
        self.descriptionLabel.text = description
    }
}

// MARK: - UISetup
private extension UPRoomCell {
    func setupUI() {
        contentView.backgroundColor = .secondaryBackground
        contentView.layer.cornerRadius = 17
        
        setupDotsButton()
        setupTitleLabel()
        setupDescriptionLabel()
        setupUnreadCount()
    }
    
    func setupDotsButton() {
        dotsButton.image = UIImage(named: "dots@24px")
        dotsButton.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            dotsButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            dotsButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -28),
            dotsButton.heightAnchor.constraint(equalToConstant: 24),
            dotsButton.widthAnchor.constraint(equalToConstant: 24)]
        
        contentView.addSubview(dotsButton)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupTitleLabel() {
        titleLabel.font = .font(ofSize: 17, weight: .semibold)
        titleLabel.textColor =  .primaryLightText
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 28),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.rightAnchor.constraint(equalTo: dotsButton.leftAnchor, constant: 28)]
        
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
    
    func setupUnreadCount() {
        unreadCountView.isHidden = true
        unreadCountView.layer.cornerRadius = 10
        unreadCountView.backgroundColor = .init(hex: "#EC133A")
        unreadCountView.translatesAutoresizingMaskIntoConstraints = false
        let viewConstraints = [
            unreadCountView.topAnchor.constraint(equalTo: contentView.topAnchor),
            unreadCountView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            unreadCountView.heightAnchor.constraint(equalToConstant: 24)]
        
        contentView.addSubview(unreadCountView)
        NSLayoutConstraint.activate(viewConstraints)
        
        unreadCountLabel.font = .font(ofSize: 14, weight: .bold)
        unreadCountLabel.textColor = .white
        unreadCountLabel.textAlignment = .center
        unreadCountLabel.translatesAutoresizingMaskIntoConstraints = false
        let labelConstraints = [
            unreadCountLabel.centerYAnchor.constraint(equalTo: unreadCountView.centerYAnchor),
            unreadCountLabel.leftAnchor.constraint(equalTo: unreadCountView.leftAnchor, constant: 10),
            unreadCountLabel.rightAnchor.constraint(equalTo: unreadCountView.rightAnchor, constant: -10)]
        
        unreadCountView.addSubview(unreadCountLabel)
        NSLayoutConstraint.activate(labelConstraints)
    }
}
