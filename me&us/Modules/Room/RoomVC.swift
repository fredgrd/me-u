//
//  RoomVC.swift
//  me&us
//
//  Created by Federico on 15/02/23.
//

import UIKit
import Combine

class RoomVC: UIViewController {
    
    private let viewModel: RoomVCViewModel
    
    private var bag = Set<AnyCancellable>()
    
    // Observers
    private var keyboardWillShowObserver: NSObjectProtocol?
    private var keyboardWillHideObserver: NSObjectProtocol?
    
    // Subviews
    private let draggableBar = UIView()
    private let headerBar = UIView()
    private let nameFieldView = UIView()
    private let nameField = UITextField()
    private let descriptionFieldView = UIView()
    private let descriptionPlaceholderLabel = UILabel()
    private let descriptionField = UITextView()
    private let createButton = PrimaryButton()
    private var createButtonBotConstraint = NSLayoutConstraint()
    
    // Init
    init(viewModel: RoomVCViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        setupUI()
        setupObservers()
        bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setupObservers() {
        keyboardWillShowObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { notification in
            guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
            }
            
            self.createButtonBotConstraint.constant = -(keyboardFrame.height + 8)
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
        
        keyboardWillHideObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { notification in
            self.createButtonBotConstraint.constant = -(self.view.safeAreaBottom + 12)
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func bindUI() {
        createButton.onClick.receive(on: RunLoop.main).sink { button in
            guard let name = self.nameField.text, let description = self.descriptionField.text else {
                return
            }
            
            
            if button.isSpinning {
                return
            }
            
            button.showSpinner()
            
            Task {
                await self.viewModel.createRoom(withName: name, description: description)
            }
            
            button.hideSpinner()
            self.dismiss(animated: true)
        }.store(in: &bag)
    }
}

extension RoomVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count <= 0 {
            descriptionPlaceholderLabel.alpha = 1
        } else {
            descriptionPlaceholderLabel.alpha = 0
        }
    }
}

// MARK: - UISetup
private extension RoomVC {
    func setupUI() {
        view.backgroundColor = .primaryBackground
        view.layer.cornerRadius = 40
        
        setupDraggableBar()
        setupHeaderBar()
        setupNameField()
        setupDescriptionField()
        setupCreateButton()
    }
    
    func setupDraggableBar() {
        draggableBar.backgroundColor = nil
        draggableBar.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            draggableBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            draggableBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            draggableBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            draggableBar.heightAnchor.constraint(equalToConstant: 30)]
        
        view.addSubview(draggableBar)
        NSLayoutConstraint.activate(constraints)
        
        let dragbar = UIView()
        dragbar.layer.cornerRadius = 2.5
        dragbar.backgroundColor = .secondaryDarkText
        dragbar.translatesAutoresizingMaskIntoConstraints = false
        let dragbarConstraints = [
            dragbar.centerXAnchor.constraint(equalTo: draggableBar.centerXAnchor),
            dragbar.centerYAnchor.constraint(equalTo: draggableBar.centerYAnchor),
            dragbar.heightAnchor.constraint(equalToConstant: 5),
            dragbar.widthAnchor.constraint(equalToConstant: 34)]
        
        draggableBar.addSubview(dragbar)
        NSLayoutConstraint.activate(dragbarConstraints)
    }
    
    func setupHeaderBar() {
        headerBar.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            headerBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            headerBar.topAnchor.constraint(equalTo: draggableBar.bottomAnchor),
            headerBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            headerBar.heightAnchor.constraint(equalToConstant: 44)]
        
        view.addSubview(headerBar)
        NSLayoutConstraint.activate(constraints)
        
        let titleLabel = UILabel()
        titleLabel.text = "Create a Room with..."
        titleLabel.font = .font(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .primaryLightText
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let labelConstraints = [
            titleLabel.leftAnchor.constraint(equalTo: headerBar.leftAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: headerBar.rightAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: headerBar.centerYAnchor)]
        
        headerBar.addSubview(titleLabel)
        NSLayoutConstraint.activate(labelConstraints)
    }
    
    func setupNameField() {
        nameFieldView.backgroundColor = .secondaryBackground
        nameFieldView.layer.cornerRadius = 17
        nameFieldView.translatesAutoresizingMaskIntoConstraints = false
        let viewConstraints = [
            nameFieldView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            nameFieldView.topAnchor.constraint(equalTo: headerBar.bottomAnchor, constant: 20),
            nameFieldView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            nameFieldView.heightAnchor.constraint(equalToConstant: 50)]
        
        view.addSubview(nameFieldView)
        NSLayoutConstraint.activate(viewConstraints)
        
        nameField.font = .font(ofSize: 17, weight: .semibold)
        nameField.textColor = .primaryLightText
        nameField.attributedPlaceholder = NSAttributedString(string: "Add a Room Title", attributes: [.font: UIFont.font(ofSize: 17, weight: .semibold), .foregroundColor: UIColor.secondaryLightText])
        nameField.keyboardAppearance = .dark
        nameField.translatesAutoresizingMaskIntoConstraints = false
        let fieldConstraints = [
            nameField.leftAnchor.constraint(equalTo: nameFieldView.leftAnchor, constant: 16),
            nameField.topAnchor.constraint(equalTo: nameFieldView.topAnchor),
            nameField.rightAnchor.constraint(equalTo: nameFieldView.rightAnchor, constant: -16),
            nameField.bottomAnchor.constraint(equalTo: nameFieldView.bottomAnchor)]
        
        nameFieldView.addSubview(nameField)
        NSLayoutConstraint.activate(fieldConstraints)
    }
    
    func setupDescriptionField() {
        descriptionFieldView.backgroundColor = .secondaryBackground
        descriptionFieldView.layer.cornerRadius = 17
        descriptionFieldView.translatesAutoresizingMaskIntoConstraints = false
        let viewConstraints = [
            descriptionFieldView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            descriptionFieldView.topAnchor.constraint(equalTo: nameFieldView.bottomAnchor, constant: 20),
            descriptionFieldView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            descriptionFieldView.heightAnchor.constraint(equalToConstant: 100)]
        
        view.addSubview(descriptionFieldView)
        NSLayoutConstraint.activate(viewConstraints)
        
        // Placeholder
        descriptionPlaceholderLabel.text = "Add a Room Description"
        descriptionPlaceholderLabel.font = .font(ofSize: 17, weight: .semibold)
        descriptionPlaceholderLabel.textColor = .secondaryLightText
        descriptionPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        let placeholderConstraints = [
            descriptionPlaceholderLabel.leftAnchor.constraint(equalTo: descriptionFieldView.leftAnchor, constant: 16),
            descriptionPlaceholderLabel.topAnchor.constraint(equalTo: descriptionFieldView.topAnchor, constant: 15),
            descriptionPlaceholderLabel.rightAnchor.constraint(equalTo: descriptionFieldView.rightAnchor, constant: -16)]
        
        descriptionFieldView.addSubview(descriptionPlaceholderLabel)
        NSLayoutConstraint.activate(placeholderConstraints)
        
        descriptionField.delegate = self
        descriptionField.font = .font(ofSize: 17, weight: .semibold)
        descriptionField.textColor = .primaryLightText
        descriptionField.backgroundColor = .clear
        descriptionField.keyboardAppearance = .dark
        descriptionField.translatesAutoresizingMaskIntoConstraints = false
        let fieldConstraints = [
            descriptionField.leftAnchor.constraint(equalTo: descriptionFieldView.leftAnchor, constant: 12),
            descriptionField.topAnchor.constraint(equalTo: descriptionFieldView.topAnchor, constant: 7),
            descriptionField.rightAnchor.constraint(equalTo: descriptionFieldView.rightAnchor, constant: -12),
            descriptionField.bottomAnchor.constraint(equalTo: descriptionFieldView.bottomAnchor, constant: -7)]
        
        descriptionFieldView.addSubview(descriptionField)
        NSLayoutConstraint.activate(fieldConstraints)
    }
    
    func setupCreateButton() {
        createButton.title = "Create"
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButtonBotConstraint = createButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(view.safeAreaBottom + 12))
        let constraints = [
            createButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createButtonBotConstraint]
        
        view.addSubview(createButton)
        NSLayoutConstraint.activate(constraints)
    }
}
