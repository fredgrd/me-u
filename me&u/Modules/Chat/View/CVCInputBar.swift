//
//  CVCInputBar.swift
//  me&u
//
//  Created by Federico on 20/02/23.
//

import UIKit
import Combine

class CVCInputBar: UIView {
    
    enum State {
        case rest
        case texting
        case recording
    }
    
    private var bag = Set<AnyCancellable>()
    
    let recordingState = PassthroughSubject<ChatVCViewModel.RecordingState, Never>()
    
    let mediaOnClick = PassthroughSubject<IconButton, Never>()
    
    let sendOnClick = PassthroughSubject<String, Never>()
    
    private var state: State = .rest
    
    private var recordingLastState: ChatVCViewModel.RecordingState = .stopRecording
    private var recordingTimer: Timer?
    private var recordingTimerCounter: Int = 0
    
    private let whitespaceRegex = NSRegularExpression("^[ \t]+|[ \t]+$")
    
    private let inputField = CVCInputField()
    private var inputFieldRxConstraint = NSLayoutConstraint()
    
    private let mediaButton = IconButton()
    private let recordButton = CVCRecordingButton()
    private let sendButton = IconButton()
    
    private let recordingView = UIView()
    private let recordingTimeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func resignFirstResponder() -> Bool {
        inputField.resignFirstResponder()
        return true
    }
    
    private func bindUI() {
        recordButton.onClick.receive(on: RunLoop.main).sink { [weak self] state in
            self?.handleRecordingState(state)
        }.store(in: &bag)
        
        mediaButton.onClick.receive(on: RunLoop.main).sink { [weak self] button in
            self?.mediaOnClick.send(button)
        }.store(in: &bag)
        
        sendButton.onClick.receive(on: RunLoop.main).sink { [weak self] _ in
            self?.handleSendText()
        }.store(in: &bag)
    }
    
    private func animateState(_ state: State) {
        guard self.state != state else {
            return
        }
        
        self.state = state
        
        switch state {
        case .rest:
            inputFieldRxConstraint.constant = -98
            UIView.animate(withDuration: 0.2) {
                self.sendButton.alpha = 0
                self.layoutIfNeeded()
            } completion: { _ in
                self.sendButton.isHidden = true
                self.recordButton.isHidden = false
                self.mediaButton.isHidden = false
            }
        case .texting:
            inputFieldRxConstraint.constant = -62
            sendButton.isHidden = false
            recordButton.isHidden = true
            mediaButton.isHidden = true
            UIView.animate(withDuration: 0.2) {
                self.sendButton.alpha = 1
                self.layoutIfNeeded()
            }
        case .recording:
            UIView.animate(withDuration: 0.2) {
                self.recordingView.alpha = 0
            }
        }
    }
}

// MARK: - Helpers
private extension CVCInputBar {
    func handleRecordingState(_ state: ChatVCViewModel.RecordingState) {
        guard state != recordingLastState else {
            return
        }
        
        recordingLastState = state
        
        if state == .startRecording {
            recordingTimeLabel.text = "00:00"
            recordingView.alpha = 0
            recordingView.isHidden = false
            recordingState.send(.startRecording)
            
            // Animations
            UIView.animate(withDuration: 0.2) {
                self.recordingView.alpha = 1
            }
                    
            let formatter = DateComponentsFormatter()
            formatter.zeroFormattingBehavior = [.pad]
            formatter.allowedUnits = [.minute, .second]
            recordingTimer = Timer(timeInterval: 1, repeats: true, block: { [weak self] _ in
                guard let self = self else {
                    return
                }
                
                self.recordingTimerCounter += 1
                guard let formattedString = formatter.string(from: TimeInterval(self.recordingTimerCounter)) else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.recordingTimeLabel.text = formattedString
                }
                
            })
         
            RunLoop.main.add(recordingTimer!, forMode: .common)
        }
        
        if state == .stopRecording {
            recordingTimerCounter = 0
            recordingTimer?.invalidate()
            recordingTimer = nil
            recordingState.send(.stopRecording)
            
            // Animations
            UIView.animate(withDuration: 0.2) {
                self.recordingView.alpha = 0
            } completion: { _ in
                self.recordingView.isHidden = false
            }
        }
        
        if state == .doneRecording {
            recordingTimer?.invalidate()
            recordingTimer = nil
            recordingState.send(.doneRecording)
            
            // Animations
            UIView.animate(withDuration: 0.2) {
                self.recordingView.alpha = 0
            } completion: { _ in
                self.recordingView.isHidden = false
                self.recordingTimerCounter = 0
            }
        }
    }
    
    func handleSendText() {
        guard let text = inputField.text else {
            return
        }
        
        let cleaned = whitespaceRegex.replace(text, with: "")
        sendOnClick.send(cleaned)
        inputField.text = nil
    }
}

// MARK: - UITextFieldDelegate
extension CVCInputBar: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else {
            sendButton.isEnabled = false
            return
        }
    
        let cleaned = whitespaceRegex.replace(text, with: "")
        
        if cleaned.count > 0 {
            animateState(.texting)
        } else {
            animateState(.rest)
        }
    }
}

// MARK: - UISetup
private extension CVCInputBar {
    func setupUI() {
        backgroundColor = .secondaryBackground
        
        setupInputField()
        setupButtons()
        setupRecordingView()
    }
    
    func setupInputField() {
        inputField.delegate = self
        inputField.layer.cornerRadius = 15
        inputField.layer.borderWidth = 0.5
        inputField.layer.borderColor = UIColor.init(hex: "#555555").cgColor
        inputField.font = .font(ofSize: 17, weight: .regular)
        inputField.textColor = .primaryLightText
        inputField.backgroundColor = .init(hex: "#2E2E2E")
        inputField.keyboardAppearance = .dark
        inputField.translatesAutoresizingMaskIntoConstraints = false
        inputFieldRxConstraint = inputField.rightAnchor.constraint(equalTo: rightAnchor, constant: -98)
        let constraints = [
            inputField.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            inputFieldRxConstraint,
            inputField.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            inputField.heightAnchor.constraint(equalToConstant: 36)]
        
        addSubview(inputField)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupButtons() {
        // Send button
        sendButton.isHidden = true
        sendButton.image = UIImage(named: "send@24pt")
        sendButton.imageTintColor = .primaryDarkText
        sendButton.layer.cornerRadius = 18
        sendButton.backgroundColor = .primaryHighlight
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        let sendConstraints = [
            sendButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            sendButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            sendButton.heightAnchor.constraint(equalToConstant: 36),
            sendButton.widthAnchor.constraint(equalToConstant: 36)]
        
        addSubview(sendButton)
        NSLayoutConstraint.activate(sendConstraints)
        
        // Record button
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        let recordConstraints = [
            recordButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            recordButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            recordButton.heightAnchor.constraint(equalToConstant: 36),
            recordButton.widthAnchor.constraint(equalToConstant: 36)]
        
        addSubview(recordButton)
        NSLayoutConstraint.activate(recordConstraints)
        
        // Media button
        mediaButton.image = UIImage(named: "media@24pt")
        mediaButton.imageTintColor = .primaryLightText
        mediaButton.translatesAutoresizingMaskIntoConstraints = false
        let mediaConstraints = [
            mediaButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            mediaButton.rightAnchor.constraint(equalTo: recordButton.leftAnchor, constant: -6),
            mediaButton.heightAnchor.constraint(equalToConstant: 36),
            mediaButton.widthAnchor.constraint(equalToConstant: 36)]
        
        addSubview(mediaButton)
        NSLayoutConstraint.activate(mediaConstraints)
    }
    
    func setupRecordingView() {
        recordingView.isHidden = true
        recordingView.backgroundColor = .secondaryBackground
        recordingView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            recordingView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            recordingView.rightAnchor.constraint(equalTo: recordButton.leftAnchor),
            recordingView.leftAnchor.constraint(equalTo: leftAnchor),
            recordingView.heightAnchor.constraint(equalToConstant: 36)]
        
        addSubview(recordingView)
        NSLayoutConstraint.activate(constraints)
        
        // Icon
        let recordingIcon = UIImageView()
        recordingIcon.image = UIImage(named: "record-filled@24pt")
        recordingIcon.tintColor = .primaryHighlight
        recordingIcon.translatesAutoresizingMaskIntoConstraints = false
        let iconConstraints = [
            recordingIcon.topAnchor.constraint(equalTo: recordingView.topAnchor, constant: 6),
            recordingIcon.leftAnchor.constraint(equalTo: recordingView.leftAnchor, constant: 16),
            recordingIcon.heightAnchor.constraint(equalToConstant: 24),
            recordingIcon.widthAnchor.constraint(equalToConstant: 24)]
        
        recordingView.addSubview(recordingIcon)
        NSLayoutConstraint.activate(iconConstraints)
        
        // Label
        recordingTimeLabel.font = .font(ofSize: 17, weight: .regular)
        recordingTimeLabel.textColor = .primaryLightText
        recordingTimeLabel.text = "00:00"
        recordingTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        let labelConstraints = [
            recordingTimeLabel.centerYAnchor.constraint(equalTo: recordingIcon.centerYAnchor),
            recordingTimeLabel.leftAnchor.constraint(equalTo: recordingIcon.rightAnchor, constant: 6)]
        
        recordingView.addSubview(recordingTimeLabel)
        NSLayoutConstraint.activate(labelConstraints)
        
        // Slide to cancel icon
        let slideIcon = UIImageView()
        slideIcon.image = UIImage(named: "arrow-lx@24pt")
        slideIcon.tintColor = .primaryLightText
        slideIcon.translatesAutoresizingMaskIntoConstraints = false
        let slideIconConstraints = [
            slideIcon.centerYAnchor.constraint(equalTo: recordingIcon.centerYAnchor),
            slideIcon.rightAnchor.constraint(equalTo: recordingView.rightAnchor, constant: -6),
            slideIcon.heightAnchor.constraint(equalToConstant: 24),
            slideIcon.widthAnchor.constraint(equalToConstant: 24)]
        
        recordingView.addSubview(slideIcon)
        NSLayoutConstraint.activate(slideIconConstraints)
        
        // Slide to cancel label
        let slideLabel = UILabel()
        slideLabel.font = .font(ofSize: 17, weight: .regular)
        slideLabel.textColor = .primaryLightText
        slideLabel.text = "slide to cancel"
        slideLabel.translatesAutoresizingMaskIntoConstraints = false
        let slideConstraints = [
            slideLabel.centerYAnchor.constraint(equalTo: recordingIcon.centerYAnchor),
            slideLabel.rightAnchor.constraint(equalTo: slideIcon.leftAnchor)]
        
        recordingView.addSubview(slideLabel)
        NSLayoutConstraint.activate(slideConstraints)
    }
}
