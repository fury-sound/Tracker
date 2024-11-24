//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Valery Zvonarev on 02.11.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowsScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowsScene)
        window?.rootViewController = SplashViewController()
//        window?.rootViewController = MainTrackerViewController()
//        window?.rootViewController = TrackerCreateVC()
        window?.makeKeyAndVisible()
    }

}

