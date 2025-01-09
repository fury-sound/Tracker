//
//  AddCategory.swift
//  Tracker
//
//  Created by Valery Zvonarev on 14.11.2024.
//

import UIKit

final class AddCategoryVC: UIViewController {
    
    private let viewModel: AddCategoryViewModel
    
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
        readyButton.setTitleColor(.ypWhite, for: .normal)
        readyButton.setTitle("Готово", for: .normal)
        readyButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        readyButton.addTarget(self, action: #selector(creatingNewCategory), for: .touchUpInside)
        return readyButton
    }()
    
    init(viewModel: AddCategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Новая категория"
        navigationItem.setHidesBackButton(true, animated: true)
        viewSetup()
        viewModel.viewDidLoad()
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
        
        viewModel.editTextFieldHandler = { [weak self] buttonEnabled in
            guard let self else { return }
            if !buttonEnabled  {
                self.readyButton.isEnabled = false
                self.readyButton.backgroundColor = .ypGray
            } else {
                self.readyButton.isEnabled = true
                self.readyButton.backgroundColor = .ypBlack
            }
        }
        
        viewModel.errorCreatingNewCategory = { [weak self] categoryName in
            self?.alertForAddCategoryError(name: categoryName)
        }
        
    }
    
    private func alertForAddCategoryError(name: String) {
        let alert = UIAlertController(title: "Ошибка!\n",
                                      message: "Категория \(name) уже существует",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    @objc func creatingNewCategory() {
        viewModel.creatingNewCategoryTapped(name: trackerNewNameTextfield.text ?? "")
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func editingFunc(_ sender: UITextField) {
        guard let text = sender.text else { return }
        viewModel.onEditingTextField(text: text)
    }
}

extension AddCategoryVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        trackerNewNameTextfield.resignFirstResponder()
        //        view.endEditing(true)
        return true
    }
}
