//
//  PageViewController.swift
//  Tracker
//
//  Created by Valery Zvonarev on 07.01.2025.
//

import UIKit

final class PageViewController: UIViewController {
    
    var imageName: String = ""
    var textLabelText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        let imageView = UIImageView(frame: self.view.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: imageName)
        
        let textLabel = UILabel()
        textLabel.text = textLabelText
        textLabel.textColor = .ypBlack
        textLabel.backgroundColor = .clear
        textLabel.numberOfLines = 2
        textLabel.font = .systemFont(ofSize: 32, weight: .bold)
        textLabel.textAlignment = .center
        
        let itemArray = [imageView, textLabel]
        itemArray.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview($0)
        }
        let topConstraint = view.frame.height * 0.53
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: topConstraint),
            textLabel.heightAnchor.constraint(equalToConstant: 78)
        ])
    }
}
