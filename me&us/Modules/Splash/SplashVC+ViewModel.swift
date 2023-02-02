//
//  SplashVC+ViewModel.swift
//  me&us
//
//  Created by Federico on 02/02/23.
//

import UIKit

class SplashVCViewModel {
    
    var controller: MainController?
    
    func onSplash() {
        guard let token = KeychainInterface.retrieve(key: "auth_token") else {
            print("NO TOKEN!")
            controller?.goToAuth()
            return
        }
    }
}
