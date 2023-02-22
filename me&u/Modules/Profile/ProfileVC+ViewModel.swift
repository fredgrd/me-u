//
//  ProfileVC+ViewModel.swift
//  me&us
//
//  Created by Federico on 16/02/23.
//

import UIKit

class ProfileVCViewModel {
    
    let controller: MainController

    init(controller: MainController) {
        self.controller = controller
    }
    
    func uploadImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            return
        }
        
        Task {
            let result = await controller.userAPI.updateAvatar(imageData)
            switch result {
            case .success(let user):
                controller.userManager.updateUser(user)
            case .failure(_):
                await controller.showToast(withMessage: "Avatar upload failed")
            }
        }
    }
    
    func signout() {
        controller.signout()
    }
}
