//
//  ChatVC+ViewModel.swift
//  me&us
//
//  Created by Federico on 12/02/23.
//

import Foundation
import Combine

class ChatVCViewModel {
    
    enum ChatSection: Hashable {
        case chat
    }
    
    let controller: MainController
    
    let room: Room
    
    let messages = CurrentValueSubject<[RoomMessage], Never>([])
    
    let typing = CurrentValueSubject<RoomUpdate?, Never>(nil)
    private var typingTimer: Timer?
    
    let webSocketAPI = WebSocketAPI()
    
    init(controller: MainController, room: Room) {
        self.controller = controller
        self.room = room
    }
    
    func fetchHistory() async {
        let result = await controller.roomAPI.fetchMessages(forRoom: room.id)
        switch result {
        case .success(let messages):
            self.messages.send(messages)
        case .failure(_):
            await controller.showToast(withMessage: ToastErrorMessage.Generic.rawValue)
        }
    }

    func subscribeToRoom() {
        webSocketAPI.subscribeToRoom(withID: room.id) { [weak self] socketResult in
            guard let self = self, let socketResult = socketResult else {
                return
            }
            
            if socketResult.kind == .update, let update = socketResult.update {
                self.typingTimer?.invalidate()
                DispatchQueue.main.async {
                    self.typingTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: false, block: { _ in
                        self.typing.send(nil)
                    })
                }
                self.typing.send(update)
            }
            
            if socketResult.kind == .message, let message = socketResult.message {
                var messages = self.messages.value
                messages.append(message)
                self.messages.send(messages)
            }
        }
    }
    
    func closeSocket() {
        webSocketAPI.closeWebSocket()
    }
    
    func sendMessage(_ text: String) async {
        guard let user = controller.userManager.user.value else {
            fatalError("Failed to retrieve user")
        }
        
        // Form RoomMessage
        let message = RoomMessage(id: UUID().uuidString, sender: user.id, sender_name: user.name, sender_number: user.number, sender_thumbnail: user.avatar_url, message: text, timestamp: Date.now.ISO8601Format())
        
        // Socket
        webSocketAPI.sendMessage(message)
        
        var messages = messages.value
        messages.append(message)
        self.messages.send(messages)
    }
    
    func sendUpdate(_ kind: RoomUpdateKind = .typing) async {
        guard let user = controller.userManager.user.value else {
            fatalError("Failed to retrieve user")
        }
        
        let update = RoomUpdate(kind: kind, sender_name: user.name)
        
        webSocketAPI.sendUpdate(update)
    }
}
