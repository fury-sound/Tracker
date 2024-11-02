//
//  AppDelegate.swift
//  Tracker
//
//  Created by Valery Zvonarev on 02.11.2024.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        window = UIWindow(frame: UIScreen.main.bounds)
        window = UIWindow()
        let rootVC = ViewController()
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
        // Override point for customization after application launch.
        return true
    }

}

