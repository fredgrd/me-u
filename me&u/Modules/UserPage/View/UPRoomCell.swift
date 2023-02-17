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
    
    private var bag = Set<AnyCancellable>()
    
    private let dotsButton = IconButton()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
}
