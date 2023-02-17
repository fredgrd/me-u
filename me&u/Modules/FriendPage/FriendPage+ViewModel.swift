//
//  FriendPage+ViewModel.swift
//  me&us
//
//  Created by Federico on 16/02/23.
//

import Foundation
import Combine

class FriendPageViewModel {
    
    let friend: UserFriendDetails
    let home: HomeVC
    let controller: MainController
    
    var rooms = CurrentValueSubject<[Room], Never>([])

    init(friend: UserFriendDetails, home: HomeVC, controller: MainController) {
        self.friend = friend
        self.home = home
        self.controller = controller
    }
    
    func fetchFriendDetails() async -> FriendDetails? {
        let result = await controller.userAPI.fetchFriendDetails(withID: friend.id)
        switch result {
        case .success(let details):
            return details
        case .failure(_):
            await controller.showToast(withMessage: ToastErrorMessage.Generic.rawValue)
            return nil
        }
    }
    
    func fetchRooms() async {
        let result = await controller.roomAPI.fetchRooms(forUser: friend.id)
        switch result {
        case .success(let rooms):
            self.rooms.send(rooms)
        case .failure(_):
            await self.controller.showToast(withMessage: ToastErrorMessage.Generic.rawValue)
        }
    }
}
