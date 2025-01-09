//
//  SplashViewController.swift
//  Tracker
//
//  Created by Valery Zvonarev on 02.11.2024.
//

import UIKit

final class SplashViewController: UIViewController {
    
    private let storage: UserDefaults = .standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSplashScreen()
//        storage.removeObject(forKey: "wasLaunched")  // to be deleted once the app is completed
        let wasLaunched = storage.bool(forKey: "wasLaunched")
        if wasLaunched {
            switchToNaviBarVC()
        } else {
            storage.set(true, forKey: "wasLaunched")
            switchToOnboardingVC()
        }
    }
    
    private func setupSplashScreen() {
        view.backgroundColor = .ypBlue
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.image = UIImage.yandexPracticumLogo
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 91),
            imageView.widthAnchor.constraint(equalToConstant: 94)
        ])
    }
        
    private func switchToOnboardingVC() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid windows configuration")
            return
        }
        let mainOnboardingVC = OnboardingViewController()
        mainOnboardingVC.modalTransitionStyle = .crossDissolve
        mainOnboardingVC.modalPresentationStyle = .fullScreen
        window.rootViewController = mainOnboardingVC
        self.dismiss(animated: true)
    }

    private func switchToNaviBarVC() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid windows configuration")
            return
        }
        let mainNaviBarVC = MainTrackerViewController()
        mainNaviBarVC.modalTransitionStyle = .crossDissolve
        mainNaviBarVC.modalPresentationStyle = .fullScreen
        window.rootViewController = mainNaviBarVC
        self.dismiss(animated: true)
    }
}
