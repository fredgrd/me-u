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
            let result = await controller.userAPI.fetchUser()
            print(result)
            switch result {
            case .success(let user):
                controller.userManager.user.send(user)
                await controller.goToHome()
            case .failure(let error):
                switch error {
                case .userError:
                    await controller.goToAuth()
                default:
                    await controller.showToast(withMessage: "Internal server error")
                }
            }
        }
    }
}
