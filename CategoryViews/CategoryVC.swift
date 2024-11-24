//
//  CategoryVC.swift
//  Tracker
//
//  Created by Valery Zvonarev on 14.11.2024.
//

import UIKit

final class CategoryVC: UIViewController {
    
    private lazy var imageView: UIImageView = {
        let image = UIImage.flyingStar
        let imageView = UIImageView(image: image)
        imageView.backgroundColor = .clear
        return imageView
    }()

    private lazy var initSlogan: UILabel = {
        let initSlogan = UILabel()
        initSlogan.backgroundColor = .clear
        initSlogan.numberOfLines = 2
        initSlogan.text = "Привычки и события можно \n объединять по смыслу"
        initSlogan.textAlignment = .center
        initSlogan.font = .systemFont(ofSize: 12, weight: .medium)
        initSlogan.textColor = .ypBlack
        initSlogan.sizeToFit()
        return initSlogan
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let createButton = UIButton()
        createButton.layer.cornerRadius = 16
        createButton.backgroundColor = .ypBlack
        createButton.setTitleColor(.ypWhite, for: .normal)
        createButton.setTitle("Добавить категорию", for: .normal)
        createButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        createButton.addTarget(self, action: #selector(addCategory), for: .touchUpInside)
        return createButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Категория"
        viewSetup()
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    private func viewSetup() {
        view.backgroundColor = .white
        let elementArray = [imageView, initSlogan, addCategoryButton]
        elementArray.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            initSlogan.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            initSlogan.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc func addCategory() {
        let addCategoryVC = AddCategoryVC()
        navigationController?.pushViewController(addCategoryVC, animated: true)
    }
    
}
