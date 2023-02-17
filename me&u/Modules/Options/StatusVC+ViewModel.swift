//
//  StatusVC+ViewModel.swift
//  me&us
//
//  Created by Federico on 15/02/23.
//

import Foundation

class StatusVCViewModel {
    
    private let controller: MainController
    
    init(controller: MainController) {
        self.controller = controller
    }
    
    func updateStatus(withEmoji emoji: String) async -> Bool {
        let result = await controller.userAPI.updateStatus(withStatus: emoji)
        switch result {
        case .success(let user):
            controller.userManager.user.send(user)
            return true
        case .failure(_):
            await controller.showToast(withMessage: ToastErrorMessage.Generic.rawValue)
            return false
        }
    }
}
