//
//  AuthNotificationsVC.swift
//  me&u
//
//  Created by Federico on 24/02/23.
//

import UIKit
import Combine

class AuthNotificationsVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private let viewModel: AuthNotificationsVCViewModel
    
    private var bag = Set<AnyCancellable>()
    
    private let acceptButton = PrimaryButton()
    private let skipButton = PrimaryButton()
    
    init(viewModel: AuthNotificationsVCViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkNotificationStatus), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    private func bindUI() {
        acceptButton.onClick.receive(on: RunLoop.main).sink { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.checkNotifications()
        }.store(in: &bag)
        
        skipButton.onClick.receive(on: RunLoop.main).sink { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.goToHome()
        }.store(in: &bag)
    }
    
    @objc private func checkNotificationStatus() {
        self.viewModel.goToHome()
    }
}

// MARK: - UISetup
private extension AuthNotificationsVC {
    func setupUI() {
        view.backgroundColor = .primaryBackground
        
        setupInfo()
    }
    
    func setupInfo() {
        let infoView = UIView()
        infoView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            infoView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            infoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoView.widthAnchor.constraint(equalToConstant: 250)]
        
        view.addSubview(infoView)
        NSLayoutConstraint.activate(constraints)
        
        // Card
        let card = UIImageView()
        card.image = UIImage(named: "notifications-card@65pt")
        card.translatesAutoresizingMaskIntoConstraints = false
        let cardConstraints = [
            card.topAnchor.constraint(equalTo: infoView.topAnchor),
            card.centerXAnchor.constraint(equalTo: infoView.centerXAnchor),
            card.heightAnchor.constraint(equalToConstant: 65),
            card.widthAnchor.constraint(equalToConstant: 81)]
        
        infoView.addSubview(card)
        NSLayoutConstraint.activate(cardConstraints)
        
        // Title
        let title = UILabel()
        title.text = "Allow notifications"
        title.font = .font(ofSize: 21, weight: .bold)
        title.textColor = .primaryLightText
        title.numberOfLines = 0
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false
        let titleConstraints = [
            title.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 20),
            title.rightAnchor.constraint(equalTo: infoView.rightAnchor),
            title.leftAnchor.constraint(equalTo: infoView.leftAnchor)]
        
        infoView.addSubview(title)
        NSLayoutConstraint.activate(titleConstraints)

        // Subtitle
        let subtitle = UILabel()
        subtitle.text = "Me&u is a live service, notifications greatly improve your experience"
        subtitle.font = .font(ofSize: 15, weight: .medium)
        subtitle.textColor = .secondaryLightText
        subtitle.numberOfLines = 0
        subtitle.textAlignment = .center
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        let subtitleConstraints = [
            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 14),
            subtitle.rightAnchor.constraint(equalTo: infoView.rightAnchor),
            subtitle.leftAnchor.constraint(equalTo: infoView.leftAnchor)]
        
        infoView.addSubview(subtitle)
        NSLayoutConstraint.activate(subtitleConstraints)
        
        // Button
        acceptButton.title = "Allow"
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        let acceptConstraints = [
            acceptButton.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 40),
            acceptButton.centerXAnchor.constraint(equalTo: infoView.centerXAnchor)]
        
        infoView.addSubview(acceptButton)
        NSLayoutConstraint.activate(acceptConstraints)
        
        // Button
        skipButton.title = "Skip"
        skipButton.titleColor = .secondaryLightText
        skipButton.backgroundColor = .clear
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        let skipConstraints = [
            skipButton.topAnchor.constraint(equalTo: acceptButton.bottomAnchor, constant: 5),
            skipButton.centerXAnchor.constraint(equalTo: infoView.centerXAnchor),
            skipButton.bottomAnchor.constraint(equalTo: infoView.bottomAnchor)]
        
        infoView.addSubview(skipButton)
        NSLayoutConstraint.activate(skipConstraints)
    }
}
