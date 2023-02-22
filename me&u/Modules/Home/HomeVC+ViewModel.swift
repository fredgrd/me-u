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
    
    func fetchRoom(_ id: String) async -> Room? {
        let result = await controller.roomAPI.fetchRoom(withID: id)
        switch result {
        case .success(let room):
            return room
        case .failure(_):
            await controller.showToast(withMessage: "Deeplink error")
            return nil
        }
    }
    
    func presentNotificationsVC(from vc: HomeVC) {
        let viewModel = NotificationsVCViewModel(controller: controller)
        let notificationsVC = NotificationsVC(viewModel: viewModel)
        vc.present(notificationsVC, animated: true)
    }
}
