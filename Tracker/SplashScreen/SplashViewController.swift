//
//  SplashViewController.swift
//  Tracker
//
//  Created by Valery Zvonarev on 02.11.2024.
//

import UIKit

final class SplashViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSplashScreen()
        switchToNaviBarVC()
    }
    
    private func setupSplashScreen() {
        let imageView = UIImageView()
        imageView.image = UIImage.yandexPracticumLogo
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
//        imageView.backgroundColor = UIColor(red: 55/256, green: 114/255, blue: 231/255, alpha: 1)
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 91),
            imageView.widthAnchor.constraint(equalToConstant: 94)
        ])
        sleep(5)
    }
    
    private func switchToNaviBarVC() {
        self.dismiss(animated: true)
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid windows configuration")
            return
        }
        let mainNaviBarVC = MainNavigationBarViewController()
        mainNaviBarVC.modalTransitionStyle = .crossDissolve
        mainNaviBarVC.modalPresentationStyle = .fullScreen
        window.rootViewController = mainNaviBarVC
    }
    
}
