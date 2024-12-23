//
//  AddCategory.swift
//  Tracker
//
//  Created by Valery Zvonarev on 14.11.2024.
//

import UIKit

final class AddCategoryVC: UIViewController {
    
    private lazy var trackerNewNameTextfield: UITextField = {
        var trackerNameTextfield = UITextField()
        trackerNameTextfield.backgroundColor = .ypLightGray
        trackerNameTextfield.layer.cornerRadius = 16
        trackerNameTextfield.placeholder = "Введите название категории"
        trackerNameTextfield.clearButtonMode = .whileEditing
        trackerNameTextfield.delegate = self
        trackerNameTextfield.addTarget(self, action: #selector(editingFunc(_ :)), for: .editingChanged)
        return trackerNameTextfield
    }()
    
    private lazy var readyButton: UIButton = {
        let readyButton = UIButton()
        readyButton.layer.cornerRadius = 16
        readyButton.backgroundColor = .ypGray
        readyButton.isEnabled = false
        readyButton.setTitleColor(.ypWhite, for: .normal)
        readyButton.setTitle("Готово", for: .normal)
        readyButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        readyButton.addTarget(self, action: #selector(creatingNewCategory), for: .touchUpInside)
        return readyButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Новая категория"
        viewSetup()
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    private func viewSetup() {
        view.backgroundColor = .white
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 20))
        trackerNewNameTextfield.leftView = paddingView
        trackerNewNameTextfield.leftViewMode = .always
        let elementArray = [trackerNewNameTextfield, readyButton]
        elementArray.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        NSLayoutConstraint.activate([
            trackerNewNameTextfield.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerNewNameTextfield.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerNewNameTextfield.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            trackerNewNameTextfield.heightAnchor.constraint(equalToConstant: 75),
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            readyButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc func creatingNewCategory() {
        alertForReviewer() 
//        let categoryVC = CategoryVC()
//        navigationController?.pushViewController(categoryVC, animated: true)
    }
    
    @objc func editingFunc(_ sender: UITextField) {
        guard let text = sender.text else { return }
        if text.isEmpty == true  {
            readyButton.isEnabled = false
            readyButton.backgroundColor = .ypGray
        } else {
            readyButton.isEnabled = true
            readyButton.backgroundColor = .ypBlack
        }
    }
    
    private func alertForReviewer() {
        let alert = UIAlertController(title: "Новая категория\n",
                                              message: "Уважаемый ревьювер)))\n" +
                                              "В задание 15-го спринта функционал данной вьюхи не предполагает быть реализованным именно в 15-ом спринте," +
                                              " он будет реализован в 16-ом спринте!\n Честное слово!!!)))\n 😉",
                                              preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                alert.addAction(action)
                present(alert, animated: true)
    }
}

extension AddCategoryVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        trackerNewNameTextfield.resignFirstResponder()
//        view.endEditing(true)
        return true
    }
}
