//
//  CVCUserImageCell.swift
//  me&u
//
//  Created by Federico on 21/02/23.
//

import UIKit

class CVCUserImageCell: UICollectionViewCell {
    static let identifier = "CVCUserImageCell"
    
    // Actions
    var imageOnTap: ((_ cell: CVCUserImageCell, _ frame: CGRect) -> Void)?
    
    // Subviews
    private let bubbleView = UIView()
    private let bubbleImage = UIImageView()
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        bubbleView.addGestureRecognizer(tapRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ imageUrl: String, showAvatar: Bool) {
        if showAvatar {
            bubbleImage.image = UIImage(named: "chat-bubble-rx@40pt")?.resizableImage(withCapInsets: UIEdgeInsets(top: 20, left: 24, bottom: 20, right: 24), resizingMode: .stretch)
        } else {
            bubbleImage.image = UIImage(named: "chat-bubble-rx-notail@40pt")?.resizableImage(withCapInsets: UIEdgeInsets(top: 20, left: 24, bottom: 20, right: 24), resizingMode: .stretch)
        }
       
        imageView.sd_setImage(with: URL(string: imageUrl))
    }
    
    @objc private func onTap() {
        guard let imageOnTap = imageOnTap else {
            return
        }
        
        var frame = imageView.frame
        frame.origin = bubbleView.convert(imageView.frame.origin, to: self)
        
        imageOnTap(self, frame)
    }
}

// MARK: - UISetup
private extension CVCUserImageCell {
    func setupUI() {
        setupBubble()
        setupBubbleImage()
        setupImageView()
    }
    
    func setupBubble() {
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bubbleView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -12),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bubbleView.leftAnchor.constraint(greaterThanOrEqualTo: contentView.leftAnchor, constant: 60)]
        
        contentView.addSubview(bubbleView)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupBubbleImage() {
        bubbleImage.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            bubbleImage.topAnchor.constraint(equalTo: bubbleView.topAnchor),
            bubbleImage.rightAnchor.constraint(equalTo: bubbleView.rightAnchor),
            bubbleImage.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
            bubbleImage.leftAnchor.constraint(equalTo: bubbleView.leftAnchor)]
        
        bubbleView.addSubview(bubbleImage)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupImageView() {
        imageView.layer.cornerRadius = 18
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            imageView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 3),
            imageView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -7),
            imageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -3),
            imageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 3)]
        
        bubbleView.addSubview(imageView)
        NSLayoutConstraint.activate(constraints)
    }
}
