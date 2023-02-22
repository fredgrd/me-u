//
//  UserPage+ViewModel.swift
//  me&us
//
//  Created by Federico on 12/02/23.
//

import Foundation
import Combine

class UserPageViewModel {
    
    let home: HomeVC
    let controller: MainController
    
    var rooms = CurrentValueSubject<[Room], Never>([])
    
    init(home: HomeVC, controller: MainController) {
        self.home = home
        self.controller = controller
    }
    
    func fetchRooms() async {
        guard let user = controller.userManager.user.value else {
            fatalError("Failed to retrieve user")
        }
        
        let result = await controller.roomAPI.fetchRooms(forUser: user.id)
        switch result {
        case .success(let rooms):
            self.rooms.send(rooms)
        case .failure(_):
            await self.controller.showToast(withMessage: ToastErrorMessage.Generic.rawValue)
        }
    }
    
    func unreadCount(forRoom id: String) -> Int {
        let notifications = controller.userManager.notifications.value.filter({ $0.room_id == id })
        let count = notifications.reduce(0) { partialResult, notification in
            return partialResult + (notification.status == .sent ? 1 : 0)
        }
        
        return count
    }
}
