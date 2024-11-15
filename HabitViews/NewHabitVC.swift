//
//  NewHabitVC.swift
//  Tracker
//
//  Created by Valery Zvonarev on 12.11.2024.
//

import UIKit


final class NewHabitVC: UIViewController {
    
    let buttonNameArray = ["Категория", "Расписание"]
    
    private lazy var trackerNameTextfield: UITextField = {
        var trackerNameTextfield = UITextField()
        trackerNameTextfield.backgroundColor = .ypLightGray
        trackerNameTextfield.layer.cornerRadius = 16
        trackerNameTextfield.clearButtonMode = .whileEditing
        trackerNameTextfield.placeholder = "Введите название трекера"
        trackerNameTextfield.addTarget(self, action: #selector(editingTrackerName(_ :)), for: .editingChanged)
        return trackerNameTextfield
    }()
    
//    private lazy var categoryButton: UIButton = {
//        let categoryButton = UIButton()
//        categoryButton.backgroundColor = .ypGray
////        categoryButton.layer.cornerRadius = 16
//        categoryButton.setTitleColor(.ypBlack, for: .normal)
//        categoryButton.setTitle("Категория", for: .normal)
//        categoryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
//        categoryButton.addTarget(self, action: #selector(categoryCreation), for: .touchUpInside)
//        categoryButton.frame.size.height = 74
//        return categoryButton
//    }()
//
//    private lazy var scheduleButton: UIButton = {
//        let scheduleButton = UIButton()
////        scheduleButton.layer.cornerRadius = 16
//        scheduleButton.backgroundColor = .ypGray
//        scheduleButton.setTitleColor(.ypBlack, for: .normal)
//        scheduleButton.setTitle("Расписание", for: .normal)
//        scheduleButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
//        scheduleButton.addTarget(self, action: #selector(scheduleCreation), for: .touchUpInside)
//        scheduleButton.frame.size.height = 74
//        return scheduleButton
//    }()
    
   private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.backgroundColor = .ypWhite
        cancelButton.layer.cornerRadius = 16
        cancelButton.setTitleColor(.ypRed, for: .normal)
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        cancelButton.layer.borderColor = UIColor.ypRed.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.addTarget(self, action: #selector(cancelHabitCreation), for: .touchUpInside)
        return cancelButton
    }()

    private lazy var createButton: UIButton = {
        let createButton = UIButton()
        createButton.layer.cornerRadius = 16
        createButton.backgroundColor = .ypGray
        createButton.isEnabled = false
        createButton.setTitleColor(.ypWhite, for: .normal)
        createButton.setTitle("Создать", for: .normal)
        createButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        createButton.addTarget(self, action: #selector(createHabit), for: .touchUpInside)
        return createButton
    }()
    
//    private lazy var fillerView: UIView = {
//        var fillerView = UIView()
//        fillerView.backgroundColor = .ypBlack
//        fillerView.frame.size.height = 1
//        return fillerView
//    }()
    
    private lazy var buttonTableView: UITableView = {
        let buttonTableView = UITableView()
        buttonTableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableCell")
        buttonTableView.backgroundColor = .ypLightGray
        buttonTableView.isScrollEnabled = false
        buttonTableView.delegate = self
        buttonTableView.dataSource = self
        buttonTableView.separatorStyle = .singleLine
        buttonTableView.separatorInset.left = 16
        buttonTableView.separatorInset.right = 16
        buttonTableView.layer.cornerRadius = 16
        buttonTableView.layer.masksToBounds = true
        buttonTableView.clipsToBounds = true
        return buttonTableView
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Новая привычка"
        viewSetup()
    }
    
    
    private func viewSetup() {
        view.backgroundColor = .ypWhite
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 20))
        trackerNameTextfield.leftView = paddingView
        trackerNameTextfield.leftViewMode = .always
//        let buttonTableView = UITableView(frame: .zero, style: .plain)
//        let buttonTableView = UITableView()

//        let buttonTableView = UILabel()
//        buttonTableView.text = "Привет"
//        buttonTableView.register(Habitiew(frame: .zero, style: .plain)

        let buttonSet = [cancelButton, createButton]
        let stackView = UIStackView(arrangedSubviews: buttonSet)
        stackView.backgroundColor = .clear
//        stackView.tintColor = .ypBlack
//        stackView.layer.cornerRadius = 16
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        
        let elementArray = [trackerNameTextfield, buttonTableView, stackView]
        elementArray.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        NSLayoutConstraint.activate([
//            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 78),
            trackerNameTextfield.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerNameTextfield.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerNameTextfield.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            trackerNameTextfield.heightAnchor.constraint(equalToConstant: 75),
//            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            stackView.topAnchor.constraint(equalTo: trackerNameTextfield.bottomAnchor, constant: 24),
//            stackView.heightAnchor.constraint(equalToConstant: 150),
            buttonTableView.topAnchor.constraint(equalTo: trackerNameTextfield.bottomAnchor, constant: 24),
            buttonTableView.heightAnchor.constraint(equalToConstant: 149),
            buttonTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
//    @objc func categoryCreation() {
//        print("category creation")
////        let newHabitVC = NewHabitVC()
////        let navigationController = UINavigationController(rootViewController: newHabitVC)
////        navigationController.modalPresentationStyle = .formSheet
////        present(navigationController, animated: true)
//    }

//    @objc func scheduleCreation() {
//        print("schedule creation")
//    }
    
    @objc func cancelHabitCreation() {
        print("cancel habit creation")
        self.dismiss(animated: true)
    }

    @objc func createHabit() {
        print("Create habit")

    }
    
    @objc func editingTrackerName(_ sender: UITextField) {
        guard let text = sender.text else { return }
//        print(text)
        if text.isEmpty == true || text.count > 38 {
            createButton.isEnabled = false
            createButton.backgroundColor = .ypGray
        } else {
            createButton.isEnabled = true
            createButton.backgroundColor = .ypBlack
        }
    }
    
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        // get the current text, or use an empty string if that failed
//        let currentText = textField.text ?? ""
//        // attempt to read the range they are trying to change, or exit if we can't
//        guard let stringRange = Range(range, in: currentText) else { return false }
//        // add their new text to the existing text
//        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
//        // make sure the result is under 38 characters
//        return updatedText.count <= 10
//    }
    
}

extension NewHabitVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            print("calling category dialog")
            let categoryVC = CategoryVC()
            navigationController?.pushViewController(categoryVC, animated: true)
        } else {
            print("calling schedule dialog")
            let scheduleVC = ScheduleVC()
            navigationController?.pushViewController(scheduleVC, animated: true)
        }
    }
}

extension NewHabitVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell") //as? HabitTableViewCell
        guard let cell else { return UITableViewCell()}
        cell.textLabel?.text = buttonNameArray[indexPath.row]
//        cell.layer.borderColor = UIColor.red.cgColor
//        buttonTableView.separatorStyle = .singleLine
        cell.backgroundColor = .ypBackgroundDay
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    

}

