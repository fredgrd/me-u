//
//  CVCRecordingButton.swift
//  me&u
//
//  Created by Federico on 20/02/23.
//

import UIKit
import Combine

class CVCRecordingButton: UIView {
    
    let onClick = PassthroughSubject<ChatVCViewModel.RecordingState, Never>()
    
    // Subviews
    private let iconView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onClick(sender: )))
        longPressGesture.minimumPressDuration = 0
        addGestureRecognizer(longPressGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onClick(sender: UILongPressGestureRecognizer) {
        if (sender.state == .began) {
            alpha = 0.8
            onClick.send(.startRecording)
        }
        
        let location = sender.location(in: self)
        if abs(location.x) > 30 || abs(location.y) > 30 {
            alpha = 1
            onClick.send(.stopRecording)
            return
        }
        
        if (sender.state == .ended) {
            alpha = 1
            onClick.send(.doneRecording)
        }
    }
}

// MARK: - UISetup
private extension CVCRecordingButton {
    func setupUI() {
        setupIconView()
    }
    
    func setupIconView() {
        iconView.image = UIImage(named: "record@24pt")
        iconView.tintColor = .primaryLightText
        iconView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor)]
        
        addSubview(iconView)
        NSLayoutConstraint.activate(constraints)
    }
}
