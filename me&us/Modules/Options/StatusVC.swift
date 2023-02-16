//
//  StatusVC.swift
//  me&us
//
//  Created by Federico on 15/02/23.
//

import UIKit
import ISEmojiView


class StatusVC: UIViewController {
    
    private let viewModel: StatusVCViewModel
    
    private let statusView: UIView
    
    private let point: CGPoint
    
    // Subviews
    private let statusPicker = UIView()
    private let emojiField = UITextField()
    
    // Init
    init(viewModel: StatusVCViewModel, statusView: UIView, point: CGPoint) {
        self.viewModel = viewModel
        self.statusView = statusView
        self.point = point
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc private func onTap() {
        self.dismiss(animated: true)
    }

    @objc private func emojiOnTap(button: UIButton) {
        guard let emoji = button.titleLabel?.text else {
            return
        }
        
        Task {
            let updated = await viewModel.updateStatus(withEmoji: emoji)
            
            if updated {
                self.dismiss(animated: true)
            }
        }
    }
    
    @objc private func selectEmojiOnTap() {
        emojiField.becomeFirstResponder()
    }
}

// MARK: - EmojiViewDelegate
extension StatusVC: EmojiViewDelegate {
    // callback when tap a emoji on keyboard
    func emojiViewDidSelectEmoji(_ emoji: String, emojiView: EmojiView) {
        // Return update
        Task {
            let updated = await viewModel.updateStatus(withEmoji: emoji)
            
            if updated {
                self.dismiss(animated: true)
            }
        }
    }
}

// MARK: - UISetup
private extension StatusVC {
    func setupUI() {
        setupBackgroundView()
        setupStatusView()
        setupStatusPicker()
        setupEmojiTextField()
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
    
    func setupStatusView() {
        statusView.frame.origin = point
        view.addSubview(statusView)
    }
    
    func setupStatusPicker() {
        statusPicker.layer.cornerRadius = 28
        statusPicker.backgroundColor = .secondaryBackground
        statusPicker.translatesAutoresizingMaskIntoConstraints = false
        let viewConstraints = [
            statusPicker.topAnchor.constraint(equalTo: statusView.bottomAnchor, constant: 10),
            statusPicker.widthAnchor.constraint(equalToConstant: 240),
            statusPicker.heightAnchor.constraint(equalToConstant: 56),
            statusPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor)]
        
        view.addSubview(statusPicker)
        NSLayoutConstraint.activate(viewConstraints)
        
        // Stack
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        let stackConstraints = [
            stack.topAnchor.constraint(equalTo: statusPicker.topAnchor, constant: 13),
            stack.rightAnchor.constraint(equalTo: statusPicker.rightAnchor, constant: -10),
            stack.bottomAnchor.constraint(equalTo: statusPicker.bottomAnchor, constant: -13),
            stack.leftAnchor.constraint(equalTo: statusPicker.leftAnchor, constant: 10)]
        
        statusPicker.addSubview(stack)
        NSLayoutConstraint.activate(stackConstraints)
        
        // Add buttons
        let statuses = ["😍", "🤣", "😎", "🫢", "😥"]
        statuses.forEach { emoji in
            let button = UIButton()
            button.addTarget(self, action: #selector(emojiOnTap(button:)), for: .touchUpInside)
            button.titleLabel?.font = .font(ofSize: 30, weight: .regular)
            button.setTitle(emoji, for: .normal)
            stack.addArrangedSubview(button)
        }
        
        let selectEmojiButton = UIButton()
        selectEmojiButton.addTarget(self, action: #selector(selectEmojiOnTap), for: .touchUpInside)
        selectEmojiButton.layer.cornerRadius = 15
        selectEmojiButton.backgroundColor = .secondaryDarkText
        selectEmojiButton.setImage(UIImage(named: "plus@15pt"), for: .normal)
        selectEmojiButton.imageView?.tintColor = .primaryBackground
        selectEmojiButton.translatesAutoresizingMaskIntoConstraints = false
        let buttonConstraints = [
            selectEmojiButton.heightAnchor.constraint(equalToConstant: 30),
            selectEmojiButton.widthAnchor.constraint(equalToConstant: 30)]
        stack.addArrangedSubview(selectEmojiButton)
        NSLayoutConstraint.activate(buttonConstraints)
    }
    
    func setupEmojiTextField() {
        let keyboardSettings = KeyboardSettings(bottomType: .categories)
        let emojiView = EmojiView(keyboardSettings: keyboardSettings)
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        emojiView.delegate = self
        
        emojiField.inputView = emojiView
        emojiField.keyboardAppearance = .dark
        emojiField.alpha = 0
        view.addSubview(emojiField)
    }
}
