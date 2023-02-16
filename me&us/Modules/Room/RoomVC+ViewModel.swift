//
//  RoomVC+ViewModel.swift
//  me&us
//
//  Created by Federico on 15/02/23.
//

import Foundation
import Combine

class RoomVCViewModel {
    
    let controller: MainController
    
    var addRoom: ((_ room: Room) -> Void)?
    
    init(controller: MainController) {
        self.controller = controller
    }

    func createRoom(withName name: String, description: String) async {
        let result = await controller.roomAPI.createRoom(withName: name, description: description)
        switch result {
        case .success(let room):
            guard let addRoom = addRoom else {
                await controller.showToast(withMessage: "Room not added")
                return
            }
            
            addRoom(room)
        case .failure(_):
           await controller.showToast(withMessage: ToastErrorMessage.Generic.rawValue)
        }
    }
}
