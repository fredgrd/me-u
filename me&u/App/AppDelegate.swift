//
//  AppDelegate.swift
//  me&us
//
//  Created by Federico on 02/02/23.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        let mainVC = MainController()
        window?.rootViewController = mainVC
        window?.makeKeyAndVisible()
            
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        DeeplinkManager.shared.openUrl(url)
        return true
    }
} 
