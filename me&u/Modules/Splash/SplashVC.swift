//
//  SplashVC.swift
//  me&us
//
//  Created by Federico on 02/02/23.
//

import UIKit

class SplashVC: UIViewController {
    
    private let viewModel: SplashVCViewModel
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    init(viewModel: SplashVCViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        viewModel.fetchUser()
    }
}

// MARK: - UISetup
private extension SplashVC {
    func setupUI() {
        view.backgroundColor = .primaryBackground
        setupLogo()
    }
    
    func setupLogo() {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "me&u")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 150)]
        
        view.addSubview(imageView)
        NSLayoutConstraint.activate(constraints)
    }
}
