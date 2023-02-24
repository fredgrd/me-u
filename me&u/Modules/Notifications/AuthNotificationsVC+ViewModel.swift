//
//  AuthNotificationsVC+ViewModel.swift
//  me&u
//
//  Created by Federico on 24/02/23.
//

import UIKit

class AuthNotificationsVCViewModel {
    
    private let controller: MainController
    
    init(controller: MainController) {
        self.controller = controller
    }
    
    func goToHome() {
        controller.goToHome(checkUNAuth: false)
    }
    
    func checkNotifications() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                DispatchQueue.main.async {
                    self.requestAuthorization()
                }
            default:
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                
                DispatchQueue.main.async {
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            print("Settings opened: \(success)") // Prints true
                        })
                    }
                }
            }
        }
    }
    
    private func requestAuthorization() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )
    }
}
