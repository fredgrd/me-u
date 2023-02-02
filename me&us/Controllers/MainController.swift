//
//  MainController.swift
//  me&us
//
//  Created by Federico on 02/02/23.
//

import UIKit

class MainController: UINavigationController {
    
    convenience init() {
        let viewModel = SplashVCViewModel()
        let splashVC = SplashVC(viewModel: viewModel)
        self.init(rootViewController: splashVC)
        viewModel.controller = self
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isNavigationBarHidden = true
    }
    
    // MARK: - Methods
    
    func goToAuth() {
        let authVC = AuthVC()
        self.pushViewController(authVC, animated: true)
    }
}
