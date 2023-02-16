//
//  HomeVC+ViewModel.swift
//  me&us
//
//  Created by Federico on 10/02/23.
//

import Foundation

class HomeVCViewModel {
    
    enum PageKind: Hashable {
        case user
        case friend
    }
    
    let controller: MainController
    
    // Variables
    
    init(controller: MainController) {
        self.controller = controller
    }
}
