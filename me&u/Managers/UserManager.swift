//
//  UserManager.swift
//  me&us
//
//  Created by Federico on 10/02/23.
//

import Combine
import Foundation

class UserManager {
    
    let user = CurrentValueSubject<User?, Never>(nil)
    
    let notifications = CurrentValueSubject<[Notification], Never>([])
    
    private let notificationAPI = NotificationAPI()
    
    init() {}
    
    func updateUser(_ user: User?) {
        self.user.send(user)
    }
    
    func fetchNotifications() async {
        let result = await notificationAPI.fetchNotifications()
        switch result {
        case .success(let retrievedNotifications):
            notifications.send(retrievedNotifications)
        case .failure(_):
            break
        }
    }
    
    func updateNotification(_ notification: Notification) async {
        let result = await notificationAPI.updateNotification(withID: notification.id, status: .read)
        switch result {
        case .success(_):
            var notifications = notifications.value
            if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                notifications[index].status = .read
                self.notifications.send(notifications)
            }
        case .failure(_):
            break
        }
    }
}
