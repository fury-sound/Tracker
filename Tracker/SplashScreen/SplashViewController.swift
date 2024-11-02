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
    }
    
    private func setupSplashScreen() {
        let imageView = UIImageView()
        imageView.image = UIImage.yandexPracticumLogo
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 55/256, green: 114/255, blue: 231/255, alpha: 1)
        imageView.backgroundColor = .clear
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 91),
            imageView.widthAnchor.constraint(equalToConstant: 94)
        ])
        
    }
    
}
