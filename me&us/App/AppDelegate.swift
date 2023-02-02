//
//  AppDelegate.swift
//  me&us
//
//  Created by Federico on 02/02/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        let mainVC = MainController()
        window?.rootViewController = mainVC
        window?.makeKeyAndVisible()
        
        return true
    }



}

