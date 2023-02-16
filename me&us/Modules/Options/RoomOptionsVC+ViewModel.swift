//
//  RoomOptionsVC+ViewModel.swift
//  me&us
//
//  Created by Federico on 15/02/23.
//

import Foundation

class RoomOptionsVCViewModel {
    
    private let controller: MainController
    
    private let roomID: String
    
    var deleteRoom: ((_ room: String) -> Void)?
    
    init(controller: MainController, roomID: String) {
        self.controller = controller
        self.roomID = roomID
    }
    
    func deleteRoom() async -> Bool {
        let result = await controller.roomAPI.deleteRoom(withID: roomID)
        switch result {
        case .success(_):
            guard let deleteRoom = deleteRoom else {
                return false
            }
            
            deleteRoom(roomID)
            
            return true
        case .failure(_):
            await controller.showToast(withMessage: ToastErrorMessage.Generic.rawValue)
            return false
        }
    }
}
