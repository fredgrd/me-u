//
//  ImageFocusVC.swift
//  me&u
//
//  Created by Federico on 22/02/23.
//

import UIKit

class ImageFocusVC: UIViewController {
    
    private let url: String
    private let frame: CGRect
    
    // Subviews
    private var snapshot: UIView?
    private let imageView = UIImageView()
    
    init(url: String, frame: CGRect) {
        self.url = url
        self.frame = frame
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .primaryBackground
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeDown))
        downSwipe.direction = UISwipeGestureRecognizer.Direction.down
        view.addGestureRecognizer(downSwipe)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateImage()
    }
    

    func setupUI(_ snapshot: UIView) {
        self.snapshot = snapshot
        view.addSubview(snapshot)
        
        setupImage()
    }
    
    @objc private func onSwipeDown() {
        self.dismiss(animated: true)
    }
}

// MARK: - Helpers
private extension ImageFocusVC {
    func animateImage() {
        UIView.animate(withDuration: 0.2) {
            self.imageView.frame = self.view.frame
            self.imageView.layer.cornerRadius = 0
            self.imageView.alpha = 1
        }
    }
}

// MARK: - UISetup
private extension ImageFocusVC {
    func setupImage() {
        guard let cellFrame = snapshot?.frame else {
            return
        }
        
        imageView.sd_setImage(with: URL(string: url))
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 18
        imageView.layer.masksToBounds = true
        imageView.enableZoom()
        imageView.alpha = 0
        imageView.backgroundColor = .primaryBackground
        imageView.frame = CGRect(x: frame.minX, y: cellFrame.minY + 3, width: frame.width, height: frame.height)
        view.addSubview(imageView)
    }
}
