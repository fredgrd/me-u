//
//  OptionsVC.swift
//  me&us
//
//  Created by Federico on 15/02/23.
//

import UIKit

class RoomOptionsVC: UIViewController {
    
    private let viewModel: RoomOptionsVCViewModel
    
    private let cellView: UIView
    private let point: CGPoint
    
    // Subview
    private let buttonView = UIView()
    
    // Init
    init(viewModel: RoomOptionsVCViewModel, point: CGPoint, view: UIView) {
        self.viewModel = viewModel
        self.cellView = view
        self.point = point
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupCellView()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc private func onTap() {
        self.dismiss(animated: true)
    }
    
    @objc private func onButtonTap() {
        Task {
            let deleted = await viewModel.deleteRoom()
            
            if deleted {
                self.dismiss(animated: true)
            }
        }
    }
}

// MARK: - UISetup
private extension RoomOptionsVC {
    func setupUI() {
        setupBackgroundView()
        setupButton()
    }
    
    func setupBackgroundView() {
        let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        view.addSubview(backgroundView)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupCellView() {
        if (point.y + cellView.frame.maxY > view.frame.height - 100) {
            cellView.frame.origin = CGPoint(x: point.x, y: view.frame.height - 100 - cellView.frame.maxY)
            buttonView.frame.origin = CGPoint(x: view.frame.maxX - 16 - 250, y: view.frame.height - 100 - cellView.frame.height - 54)
        } else {
            cellView.frame.origin = point
            buttonView.frame.origin = CGPoint(x: view.frame.maxX - 16 - 250, y: point.y - 54)
        }
        view.addSubview(cellView)
        view.addSubview(buttonView)
    }
    
    func setupButton() {
        buttonView.frame = CGRect(x: 0, y: 0, width: 250, height: 44)
        buttonView.backgroundColor = .secondaryBackground
        buttonView.layer.cornerRadius = 14
        
        let titleLabel = UILabel()
        titleLabel.text = "Delete"
        titleLabel.font = .font(ofSize: 17, weight: .regular)
        titleLabel.textColor = .init(hex: "#F4443B")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let labelConstraints = [
            titleLabel.leftAnchor.constraint(equalTo: buttonView.leftAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: buttonView.centerYAnchor)]
        
        buttonView.addSubview(titleLabel)
        NSLayoutConstraint.activate(labelConstraints)
        
        let icon = UIImageView()
        icon.image = UIImage(named: "trash@16pt")
        icon.translatesAutoresizingMaskIntoConstraints = false
        let iconConstraints = [
            icon.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 16),
            icon.rightAnchor.constraint(equalTo: buttonView.rightAnchor, constant: -16),
            icon.heightAnchor.constraint(equalToConstant: 16),
            icon.widthAnchor.constraint(equalToConstant: 16),
            icon.centerYAnchor.constraint(equalTo: buttonView.centerYAnchor)]
        
        buttonView.addSubview(icon)
        NSLayoutConstraint.activate(iconConstraints)
        
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onButtonTap))
        buttonView.addGestureRecognizer(tapRecognizer)
    }
}
