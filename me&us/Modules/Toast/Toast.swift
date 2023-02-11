//
//  Toast.swift
//  me&us
//
//  Created by Federico on 03/02/23.
//

import UIKit

class Toast: UIView {
    
    enum Kind: String {
        case Error = "Error"
        case Message = "Message"
    }
    
    private let container: UIView
    
    private var kind: Kind = .Message
    
    // Subviews
    private let titleLbl = UILabel()
    private let messageLbl = UILabel()
    
    required init(in view: UIView) {
        self.container = view
        super.init(frame: CGRect(x: (view.frame.width - 200)/2, y: -50, width: 200, height: 50))
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(withMessage message: String, title: String? = nil, kind: Kind = .Message) {
        titleLbl.text = title ?? kind.rawValue
        messageLbl.text = message
    }
    
    func show(withDuration delay: Double = 3) {
        self.container.addSubview(self)
        UIView.animate(withDuration: 0.2) {
            self.frame = CGRect(x: self.frame.minX, y: self.container.safeAreaTop + 6, width: 200, height: 50)
        }
        
        UIView.animate(withDuration: 0.1, delay: delay) {
            self.alpha = 0
        } completion: { _ in
            self.hide()
        }
    }
    
    func hide() {
        self.removeFromSuperview()
    }
}

// MARK: -UISetup
private extension Toast {
    func setupUI() {
        backgroundColor = .init(hex: "#454549")
        layer.cornerRadius = 25
        
        setupLabels()
    }
    
    func setupLabels() {
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.textAlignment = .center
        titleLbl.numberOfLines = 1
        titleLbl.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLbl.textColor = .white
        let titleConstraints = [
            titleLbl.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 25),
            titleLbl.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -25),
            titleLbl.topAnchor.constraint(equalTo: self.topAnchor, constant: 7)]
        
        messageLbl.translatesAutoresizingMaskIntoConstraints = false
        messageLbl.textAlignment = .center
        messageLbl.numberOfLines = 1
        messageLbl.font = .systemFont(ofSize: 13, weight: .semibold)
        messageLbl.textColor = .quickSilver
        let messageConstraints = [
            messageLbl.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 25),
            messageLbl.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -25),
            messageLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 3)]
        
        
        self.addSubview(titleLbl)
        NSLayoutConstraint.activate(titleConstraints)
        
        self.addSubview(messageLbl)
        NSLayoutConstraint.activate(messageConstraints)
    }
}
