//
//  ManageFriendsVC+ViewModel.swift
//  me&us
//
//  Created by Federico on 17/02/23.
//

import Foundation
import Combine

class ManageFriendsVCViewModel {
    
    enum Section {
        case main
    }
    
    let controller: MainController
    
    init(controller: MainController) {
        self.controller = controller
    }
    
    func deleteFriend(withID id: String) async {
        let result = await controller.userAPI.deleteFriend(withID: id)
        switch result {
        case .success(let user):
            controller.userManager.user.send(user)
        case .failure(_):
            await controller.showToast(withMessage: "Could not delete")
        }
    }
}
