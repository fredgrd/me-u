//
//  SplashVC+ViewModel.swift
//  me&us
//
//  Created by Federico on 02/02/23.
//

import UIKit

class SplashVCViewModel {
    
    var controller: MainController?
    
    func fetchUser() {
        guard let controller = controller else {
            fatalError("AuthController was not instantiated")
        }
        
        Task {
            let result = await controller.userManager.fetchUser()
            switch result {
            case .success:
                checkAuth()
            case .failure:
                await controller.goToAuth()
            }
        }
    }
    
    func checkAuth() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    self.controller!.goToHome()
                }
            } else {
                DispatchQueue.main.async {
                    self.controller!.goToAuthNotifications()
                }
            }
        }
    }
}
