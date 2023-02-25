//
//  AppDelegate.swift
//  me&us
//
//  Created by Federico on 02/02/23.
//

import UIKit
import FirebaseCore
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let gcmMessageIDKey = "gcm.Message_ID"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // [START Application Entry]
        
        window = UIWindow()
        let mainVC = MainController()
        window?.rootViewController = mainVC
        window?.makeKeyAndVisible()
            
        // Cookies
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
                
        // [END Application Entry]
        
        // [START Firebase]
        
        FirebaseApp.configure()
        
        // Push notifications
        UNUserNotificationCenter.current().delegate = self

        application.registerForRemoteNotifications()
        
        // Messaging Delegate
        Messaging.messaging().delegate = self
        
        // [END Firebase]

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        DeeplinkManager.shared.openUrl(url)
        return true
    }
} 

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Notification when app is on foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        if let controller = window?.rootViewController as? MainController {
            await controller.userManager.fetchNotifications()
        }
        
        return [[.list, .sound]]
    }
    
    // Notification when app is background
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        
        if let controller = window?.rootViewController as? MainController {
            await controller.userManager.fetchNotifications()
        }
            
        if let notification = userInfo["aps"] as? [String: Any], let category = notification["category"] as? String, let url = URL(string: category) {
            DeeplinkManager.shared.openUrl(url)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        return UIBackgroundFetchResult.newData
    }

}

// MARK: - MessagingDelegate

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token: \(String(describing: fcmToken))")
    }
}
