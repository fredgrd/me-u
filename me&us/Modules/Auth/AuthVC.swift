//
//  AuthVC.swift
//  me&us
//
//  Created by Federico on 02/02/23.
//

import UIKit
import Combine
import PhoneNumberKit

class AuthVC: UIViewController {
    
    let viewModel: AuthVCViewModel
    
    private let phoneNumberKit = PhoneNumberKit()
    
    private let alphaRegex = NSRegularExpression("[a-zA-Z]+")
    
    // Subscribers
    private var bag = Set<AnyCancellable>()
    
    // Observers
    private var keyboardWillShowObserver: NSObjectProtocol?
    private var keyboardWillHideObserver: NSObjectProtocol?
    
    private var bubblePrompts = [UIView]()
    
    // Subviews
    private let navigationBar = UIStackView()
    private var navigationBarBotAnchor = NSLayoutConstraint()
    private let disclaimerView = UIStackView()
    private let arrowLxBtn = IconButton()
    private let arrowRxBtn = IconButton()
    private let userInputView = UIView()
    private let messagePromptTop = UIView()
    private let messagePromptBot = UIView()
    
    private let numberTextField = ITPhoneNumberTextField()
    private let codeTextField = UITextField()
    private let nameTextField = UITextField()
    
    init(viewModel: AuthVCViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupUI()
        
        setupObservers()
        
        bindUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        numberTextField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        numberTextField.becomeFirstResponder()
    }
    
    deinit {
        guard let keyboardWillShowObserver = keyboardWillShowObserver, let keyboardWillHideObserver = keyboardWillHideObserver else {
            return
        }
        
        NotificationCenter.default.removeObserver(keyboardWillShowObserver)
        NotificationCenter.default.removeObserver(keyboardWillHideObserver)
    }
    
    private func bindUI() {
        viewModel.step.receive(on: DispatchQueue.main).sink(receiveValue: { step in
            switch step {
            case .number:
                self.arrowLxBtn.isEnabled = false
                self.arrowLxBtn.alpha = 0
                self.arrowRxBtn.isEnabled = false
//                self.numberTextField.becomeFirstResponder()
                self.codeTextField.isHidden = true
                self.numberTextField.isHidden = false
                
                self.setupNumberDisclaimer()
                self.removePrompts {
                    self.setupPromptBubbles(firstMessage: "Hi 👋", secondMessage: "What's your number?")
                }
            case .code:
                self.arrowLxBtn.isEnabled = true
                self.arrowRxBtn.isEnabled = false
                self.codeTextField.becomeFirstResponder()
                self.numberTextField.isHidden = true
                self.codeTextField.isHidden = false
                
                self.setupCodeDisclaimer()
                self.removePrompts {
                    self.setupPromptBubbles(firstMessage: "Sent!", secondMessage: "Input the code 👇")
                }
            case .name:
                self.arrowLxBtn.isEnabled = false
                self.arrowRxBtn.isEnabled = false
                self.arrowLxBtn.alpha = 0
                self.nameTextField.becomeFirstResponder()
                self.codeTextField.isHidden = true
                self.nameTextField.isHidden = false
                
                self.setupNameDisclaimer()
                self.removePrompts {
                    self.setupPromptBubbles(firstMessage: "🎉", secondMessage: "What's your name?")
                }
            }
        }).store(in: &bag)
        
        arrowLxBtn.onClick.receive(on: DispatchQueue.main).sink { _ in
            switch self.viewModel.step.value {
            case .code:
                self.viewModel.step.send(.number)
            default:
                break
            }
        }.store(in: &bag)
        
        arrowRxBtn.onClick.receive(on: DispatchQueue.main).sink { _ in
            switch self.viewModel.step.value {
            case .number:
                guard let phoneNumber = self.numberTextField.phoneNumber else {
                    return
                }
            
                self.arrowRxBtn.showSpinner()
                
                let formattedNumber = self.phoneNumberKit.format(phoneNumber, toType: .e164)
                
                Task {
                    await self.viewModel.startVerification(withNumber: formattedNumber)
                    self.arrowRxBtn.hideSpinner()
                }
            case .code:
                guard let code = self.codeTextField.text else {
                    return
                }
                
                self.arrowRxBtn.showSpinner()
                
                Task {
                    await self.viewModel.completeVerification(code: code)
                    self.arrowRxBtn.hideSpinner()
                }
            case .name:
                guard let name = self.nameTextField.text else {
                    return
                }
                
                self.arrowRxBtn.showSpinner()
                
                Task {
                    await self.viewModel.createUser(name: name)
                    self.arrowRxBtn.hideSpinner()
                }
            }
        }.store(in: &bag)
    }
    
    private func setupObservers() {
        keyboardWillShowObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { notification in
            guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
            }
            
            self.navigationBarBotAnchor.constant = -(keyboardFrame.height + 8)
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
        
        keyboardWillHideObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { notification in
            self.navigationBarBotAnchor.constant = -(self.view.safeAreaBottom + 12)
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // Helpers
    private func removePrompts(completion: @escaping(() -> Void)) {
            UIView.animate(withDuration: 0.2) {
                self.bubblePrompts.forEach { view in
                    view.alpha = 0
                    view.transform = CGAffineTransform(translationX: 0, y: -100)
                }
            } completion: { completed in
                if completed {
                    self.bubblePrompts.forEach { $0.removeFromSuperview() }
                    completion()
                }
            }
    }
}

// MARK: - TextFieldDelegate
extension AuthVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 2 && alphaRegex.matches(string) {
            return false
        }
        
        if textField.tag == 2 && (textField.text ?? "").count == 6 && string.count > 0 {
            return false
        }
        
        if textField.tag == 3 && (alphaRegex.matches(string) || string.count == 0) {
            return true
        } else if textField.tag == 3 {
            return false
        }
        
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.tag == 1 {
            let isValid = phoneNumberKit.isValidPhoneNumber(textField.text ?? "")
            arrowRxBtn.isEnabled = isValid
        }
        
        if textField.tag == 2 {
            arrowRxBtn.isEnabled = (textField.text ?? "").count == 6
        }
        
        if textField.tag == 3 {
            arrowRxBtn.isEnabled = (textField.text ?? "").count > 0
        }
    }
}

// MARK: - UISetup
private extension AuthVC {
    func setupUI() {
        view.backgroundColor = .init(hex: "#FCF6EF")
   
        setupNavigationBar()
        setupUserInputView()
        setupNumberTextField()
        setupCodeTextField()
        setupNameTextField()
    }
    
    func setupNavigationBar() {
        navigationBar.axis = .horizontal
        navigationBar.spacing = 16
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBarBotAnchor = navigationBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(view.safeAreaBottom + 12))
        let constraints = [
            navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
            navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8),
            navigationBarBotAnchor,
            navigationBar.heightAnchor.constraint(equalToConstant: 44)]
        
        view.addSubview(navigationBar)
        NSLayoutConstraint.activate(constraints)
        
        // Arrow left
        arrowLxBtn.image = UIImage(named: "arrow-lx@24pt")
        arrowLxBtn.alpha = 0
        arrowLxBtn.translatesAutoresizingMaskIntoConstraints = false
        let arrowLxConstraints = [
            arrowLxBtn.heightAnchor.constraint(equalToConstant: 44),
            arrowLxBtn.widthAnchor.constraint(equalToConstant: 44)
        ]
        
        navigationBar.addArrangedSubview(arrowLxBtn)
        NSLayoutConstraint.activate(arrowLxConstraints)
        
        // Disclaimer view
        disclaimerView.axis = .vertical
        disclaimerView.alignment = .center
        disclaimerView.translatesAutoresizingMaskIntoConstraints = false
        let disclaimerConstraints = [
            disclaimerView.heightAnchor.constraint(equalToConstant: 44),
            disclaimerView.widthAnchor.constraint(equalTo: navigationBar.widthAnchor, constant: -120) // 16 + 88 + 16
        ]
        
        navigationBar.addArrangedSubview(disclaimerView)
        NSLayoutConstraint.activate(disclaimerConstraints)
        
        // Arrow left
        arrowRxBtn.image = UIImage(named: "arrow-rx@24pt")
        arrowRxBtn.translatesAutoresizingMaskIntoConstraints = false
        let arrowRxConstraints = [
            arrowRxBtn.heightAnchor.constraint(equalToConstant: 44),
            arrowRxBtn.widthAnchor.constraint(equalToConstant: 44)
        ]
        
        navigationBar.addArrangedSubview(arrowRxBtn)
        NSLayoutConstraint.activate(arrowRxConstraints)
    }
    
    func setupNumberDisclaimer() {
        let label = UILabel()
        label.font = .font(ofSize: 11, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .dimGray
        label.text = "We will send a text with a verification code. Message and data rates may apply."
        
        disclaimerView.subviews.forEach {$0.removeFromSuperview()}
        disclaimerView.addArrangedSubview(label)
    }
    
    func setupCodeDisclaimer() {
        let label = UILabel()
        label.font = .font(ofSize: 11, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .dimGray
        label.text = "Code sent to \(viewModel.number ?? "")"
        
        disclaimerView.subviews.forEach {$0.removeFromSuperview()}
        disclaimerView.addArrangedSubview(label)
    }
    
    func setupNameDisclaimer() {
        let label = UILabel()
        label.font = .font(ofSize: 11, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .dimGray
        label.text = "By tapping next, you are agreeing to our Terms of Service and Privacy Policy"
        
        disclaimerView.subviews.forEach {$0.removeFromSuperview()}
        disclaimerView.addArrangedSubview(label)
    }
    
    private func setupUserInputView() {
        userInputView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            userInputView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40),
            userInputView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40),
            userInputView.bottomAnchor.constraint(equalTo: navigationBar.topAnchor, constant: -8),
            userInputView.heightAnchor.constraint(equalToConstant: 60)]
        
        view.addSubview(userInputView)
        NSLayoutConstraint.activate(constraints)
        
        let bubbleImage = UIImageView()
        bubbleImage.image = UIImage(named: "auth-bubble-right@60pt")?.resizableImage(withCapInsets: UIEdgeInsets(top: 30, left: 38, bottom: 30, right: 38), resizingMode: .stretch)
        bubbleImage.translatesAutoresizingMaskIntoConstraints = false
        let bubbleConstraints = [
            bubbleImage.leftAnchor.constraint(equalTo: userInputView.leftAnchor),
            bubbleImage.topAnchor.constraint(equalTo: userInputView.topAnchor),
            bubbleImage.rightAnchor.constraint(equalTo: userInputView.rightAnchor),
            bubbleImage.bottomAnchor.constraint(equalTo: userInputView.bottomAnchor)]
        
        userInputView.addSubview(bubbleImage)
        NSLayoutConstraint.activate(bubbleConstraints)
    }
    
    func setupNumberTextField() {
        numberTextField.delegate = self
        numberTextField.tag = 1
        numberTextField.withFlag = true
        numberTextField.font = .font(ofSize: 21, weight: .semibold)
        numberTextField.textColor = .white
        numberTextField.withExamplePlaceholder = true
        numberTextField.isHidden = true
        numberTextField.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            numberTextField.leftAnchor.constraint(equalTo: userInputView.leftAnchor, constant: 30),
            numberTextField.rightAnchor.constraint(equalTo: userInputView.rightAnchor, constant: -38),
            numberTextField.centerYAnchor.constraint(equalTo: userInputView.centerYAnchor)
        ]
        
        userInputView.addSubview(numberTextField)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupCodeTextField() {
        codeTextField.delegate = self
        codeTextField.tag = 2
        codeTextField.font = .font(ofSize: 21, weight: .semibold)
        codeTextField.textAlignment = .center
        codeTextField.textColor = .white
        codeTextField.attributedPlaceholder = NSAttributedString(string: "123456", attributes: [.font: UIFont.font(ofSize: 21, weight: .semibold), .foregroundColor: UIColor.quickSilver])
        codeTextField.keyboardType = .numberPad
        codeTextField.textContentType = .oneTimeCode
        codeTextField.isHidden = true
        codeTextField.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            codeTextField.leftAnchor.constraint(equalTo: userInputView.leftAnchor, constant: 30),
            codeTextField.rightAnchor.constraint(equalTo: userInputView.rightAnchor, constant: -38),
            codeTextField.centerYAnchor.constraint(equalTo: userInputView.centerYAnchor)
        ]
        
        userInputView.addSubview(codeTextField)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupNameTextField() {
        nameTextField.delegate = self
        nameTextField.tag = 3
        nameTextField.font = .font(ofSize: 21, weight: .semibold)
        nameTextField.textAlignment = .center
        nameTextField.textColor = .white
        nameTextField.keyboardType = .namePhonePad
        nameTextField.textContentType = .name
        nameTextField.isHidden = true
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            nameTextField.leftAnchor.constraint(equalTo: userInputView.leftAnchor, constant: 30),
            nameTextField.rightAnchor.constraint(equalTo: userInputView.rightAnchor, constant: -38),
            nameTextField.centerYAnchor.constraint(equalTo: userInputView.centerYAnchor)
        ]
        
        userInputView.addSubview(nameTextField)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupPromptBubbles(firstMessage: String, secondMessage: String) {
        let topBubble = AuthBubblePrompt(message: firstMessage)
        
        let topMessage = (firstMessage as NSString)
        let topSize = topMessage.boundingRect(with: CGSize(width: view.frame.width - 100, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [.font : UIFont.font(ofSize: 21, weight: .semibold)], context: nil)
        
        topBubble.frame = CGRect(x: 50, y: 100, width: ceil(topSize.width + 68), height: ceil(topSize.height + 32))
        topBubble.center = CGPoint(x: 50, y: 200)
        topBubble.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        topBubble.alpha = 0
        view.addSubview(topBubble)
        UIView.animate(withDuration: 0.3) {
            topBubble.alpha=1
            topBubble.center = CGPoint(x: (ceil(topSize.width + 68)/2)+50, y: 130)
            topBubble.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        
        let botBubble = AuthBubblePrompt(message: secondMessage)
        
        let botMessage = (secondMessage as NSString)
        let botSize = botMessage.boundingRect(with: CGSize(width: view.frame.width - 100, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [.font : UIFont.font(ofSize: 21, weight: .semibold)], context: nil)
        
        botBubble.frame = CGRect(x: 30, y: 200, width: ceil(botSize.width + 68), height: ceil(botSize.height + 32))
        botBubble.center = CGPoint(x: 30, y: 230)
        botBubble.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        botBubble.alpha = 0
        view.addSubview(botBubble)
        UIView.animate(withDuration: 0.3, delay: 0.1) {
            botBubble.alpha=1
            botBubble.center = CGPoint(x: (ceil(botSize.width + 68)/2)+30, y: 206)
            botBubble.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        
        bubblePrompts.append(contentsOf: [topBubble, botBubble])
    }
}
