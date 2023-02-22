//
//  NotificationsVC+ViewModel.swift
//  me&u
//
//  Created by Federico on 19/02/23.
//

import Foundation
import Combine

class NotificationsVCViewModel {
    
    let controller: MainController
    
    let notifications: CurrentValueSubject<[Notification], Never>
    
    init(controller: MainController) {
        self.controller = controller
        self.notifications = controller.userManager.notifications
    }
    
    func fetchNotifications() {
        Task {
            await controller.userManager.fetchNotifications()
        }
    }
    
    func updateNotification(_ notification: Notification) {
        Task {
            await controller.userManager.updateNotification(notification)
        }
    }
}
