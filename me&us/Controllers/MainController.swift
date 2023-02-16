//
//  MainController.swift
//  me&us
//
//  Created by Federico on 02/02/23.
//

import UIKit

class MainController: UINavigationController {
    
    private var toast: Toast?
    
    let userManager = UserManager()
    
    let authAPI = AuthAPI()
    
    let userAPI = UserAPI()
    
    let roomAPI = RoomAPI()
    
    init() {
        let splashVM = SplashVCViewModel()
        let splashVC = SplashVC(viewModel: splashVM)
        super.init(rootViewController: splashVC)
        splashVM.controller = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isNavigationBarHidden = true
    }
    
    func showToast(withMessage message: String) {
        if var topController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            if let view = topController.view {
                toast?.hide()
                toast = Toast(in: view)
                toast!.set(withMessage: message)
                toast!.show()
            }
        }
    }
}

// MARK: - Navigation
extension MainController {
    func goToAuth() {
        let authVM = AuthVCViewModel(controller: self)
        let authVC = AuthVC(viewModel: authVM)
        self.pushViewController(authVC, animated: true)
    }
    
    func goToHome() {
        let homeVM = HomeVCViewModel(controller: self)
        let homeVC = HomeVC(viewModel: homeVM)
        self.pushViewController(homeVC, animated: true)
    }
}
