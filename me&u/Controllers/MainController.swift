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
    
    func signout() {
        guard let url = URL(string: "https://api.dinolab.one"), let cookies = HTTPCookieStorage.shared.cookies(for: url) else {
            return
        }
        
        cookies.forEach { cookie in
            HTTPCookieStorage.shared.deleteCookie(cookie)
        }
        
        let authVM = AuthVCViewModel(controller: self)
        let authVC = AuthVC(viewModel: authVM)
        self.revertTo(viewController: authVC, animated: true) { [weak self] in
            guard let self = self else {
                return
            }

            guard var navigationArray = self.navigationController?.viewControllers, let last = navigationArray.last else {
                return
            }

            navigationArray.removeAll()
            navigationArray.append(last)
            
            self.navigationController?.viewControllers = navigationArray
            
            guard let url = URL(string: "https://api.dinolab.one"), let cookies = HTTPCookieStorage.shared.cookies(for: url) else {
                return
            }
            
            cookies.forEach { cookie in
                HTTPCookieStorage.shared.deleteCookie(cookie)
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
    
    func goToProfile() {
        let profileVM = ProfileVCViewModel(controller: self)
        let profileVC = ProfileVC(viewModel: profileVM)
        self.pushViewControllerFromLeft(controller: profileVC)
    }
}
