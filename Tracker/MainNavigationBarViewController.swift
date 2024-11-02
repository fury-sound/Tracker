//
//  MainNavigationBarViewController.swift
//  Tracker
//
//  Created by Valery Zvonarev on 02.11.2024.
//

import UIKit

final class MainNavigationBarViewController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainNavBarVC()
    }
    
    private func setupMainNavBarVC() {
        view.backgroundColor = .white
        let image = UIImage.flyingStar
        let imageView = UIImageView(image: image)
        let initLogo = UILabel()
        initLogo.text = "Что будем отслеживать?"
        initLogo.font = UIFont(name: "SFPro", size: 12)
        initLogo.textColor = .ypBlack
        initLogo.sizeToFit()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        initLogo.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        view.addSubview(imageView)
        view.addSubview(initLogo)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            initLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            initLogo.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8)
        ])
        self.tabBarItem 
        
    }
}
