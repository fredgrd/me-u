//
//  UserManager.swift
//  me&us
//
//  Created by Federico on 10/02/23.
//

import Combine
import Foundation
import FirebaseMessaging
import os

class UserManager {
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: UserManager.self))
    
    private let userAPI = UserAPI()
    
    let user = CurrentValueSubject<User?, Never>(nil)
    
    let notifications = CurrentValueSubject<[Notification], Never>([])
    
    private let notificationAPI = NotificationAPI()
    
    init() {}
    
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

// MARK: - Helpers

extension UserManager {
    func updateUser(_ user: User?) {
        self.user.send(user)
    }
}

// MARK: - Async User Methods

extension UserManager {
    func createUser(_ name: String) async -> OperationResult {
        // Get token from firebase messaging
        guard let token = try? await Messaging.messaging().token()  else {
            logger.error("Could not retrieve FCM token")
            return .failure
        }
        
        let result = await userAPI.createUser(withName: name, token: token)
        switch result {
        case .success(let user):
            self.user.send(user)
            return .success
        case .failure(let error):
            self.logger.error("Failed to create user \(error)")
            return .failure
        }
    }
    
    func fetchUser() async -> OperationResult {
        let result = await userAPI.fetchUser()
        switch result {
        case .success(let user):
            // Check if fcm_token matches
            if let token = try? await Messaging.messaging().token(), token != user.fcm_token {
                self.logger.trace("Tokens do not match - updating")
                let updateResult = await userAPI.updateToken(withToken: token)
                switch updateResult {
                case.success(let updatedUser):
                    self.logger.trace("Retrieved updated user")
                    self.user.send(updatedUser)
                    return .success
                case .failure(let error):
                    self.logger.error("Failed to fetch updated user \(error)")
                    return .failure
                }
            }
            
            self.logger.trace("Retrieved user")
            self.user.send(user)
            return .success
        case .failure(let error):
            self.logger.error("Failed to fetch user \(error)")
            return .failure
        }
    }
    
    func updateUser() async -> OperationResult {
        return .success
    }
}
