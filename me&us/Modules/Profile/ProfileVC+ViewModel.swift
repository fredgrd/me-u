//
//  ProfileVC+ViewModel.swift
//  me&us
//
//  Created by Federico on 16/02/23.
//

import UIKit
import Cloudinary

class ProfileVCViewModel {
    
    let controller: MainController
    
    private let cloudinary: CLDCloudinary
    
    init(controller: MainController) {
        self.controller = controller
        let config = CLDConfiguration(cloudName: "degzh4mwt", apiKey: "381569676437882")
        cloudinary = CLDCloudinary(configuration: config)
    }
    
    func uploadImage(_ image: UIImage) {
        guard let imageData = image.pngData() else {
            return
        }
        
        let preprocessChain = CLDImagePreprocessChain().addStep(CLDPreprocessHelpers.limit(width: 300, height: 300))
        
        cloudinary.createUploader().upload(data: imageData, uploadPreset: "tbyqh1lp", preprocessChain: preprocessChain, completionHandler:  { [weak self] response, error in
            guard let self = self else {
                return
            }
            
            if error != nil {
                self.controller.showToast(withMessage: "Image upload failed")
                return
            }
            
            if let url = response?.secureUrl {
                Task {
                    let result = await self.controller.userAPI.updateAvatar(withURL: url)
                    switch result {
                    case .success(let user):
                        self.controller.userManager.user.send(user)
                    case .failure(_):
                        await self.controller.showToast(withMessage: ToastErrorMessage.Generic.rawValue)
                    }
                }
            } else {
                self.controller.showToast(withMessage: "Image upload failed")
            }
        })
    }
    
    func signout() {
        controller.signout()
    }
}
