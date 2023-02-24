//
//  AuthVC+ViewModel.swift
//  me&us
//
//  Created by Federico on 02/02/23.
//

import Combine
import Foundation

class AuthVCViewModel {
    
    enum Step {
        case number
        case code
        case name
    }
    
    let controller: MainController
    
    let authAPI = AuthAPI()
    let userAPI = UserAPI()
    
    let step = CurrentValueSubject<Step, Never>(.number)
    
    var number: String?
    
    var signupToken: String?
    
    init(controller: MainController) {
        self.controller = controller
    }
    
    func startVerification(withNumber number: String) async {
        self.number = number

        let result = await authAPI.startVerification(withNumber: number)
        switch result {
        case .success(_):
            step.send(.code)
        case .failure(let error):
            switch error {
            case .userError:
                await controller.showToast(withMessage: "Invalid number")
            default:
                await controller.showToast(withMessage: "Internal server error")
            }
        }
    }
    
    func completeVerification(code: String) {
        guard let number = number else {
            return
        }
        
        Task {
            let result = await authAPI.completeVerification(withCode: code, number: number)
            switch result {
            case .success(let verificationResult):
                if let user = verificationResult.user {
                    self.controller.userManager.updateUser(user)
                    await self.controller.goToHome()
                } else {
                    step.send(.name)
                }
            case .failure(let error):
                switch error {
                case .userError:
                    await controller.showToast(withMessage: "Invalid code")
                default:
                    await controller.showToast(withMessage: "Internal server error")
                }
            }
        }
    }
    
    func createUser(name: String) {
        Task {
            let result = await controller.userManager.createUser(name)
            switch result {
            case .success:
                await self.controller.goToHome()
            case .failure:
                await controller.showToast(withMessage: "Operation failed")
            }
        }
    }
}
