//
//  NewHabitVC.swift
//  Tracker
//
//  Created by Valery Zvonarev on 12.11.2024.
//

import UIKit

protocol TrackerNavigationViewProtocol: AnyObject {
    func addingTrackerOnScreen(trackerName: String, trackerCategory: String, dateArray: [ScheduledDays])
}

protocol TrackerCreateVCProtocol: AnyObject {
    func getDelegateTracker() -> TrackerNavigationViewProtocol
}

final class NewHabitVC: UIViewController {

    var daysToSend = [ScheduledDays]()
    let buttonNameArray = [("Категория", "Название категории"), ("Расписание", "Дни недели")]
    weak var delegateTrackerInNewHabitVC: TrackerCreateVCProtocol?
    private var categoryCell = UITableViewCell()
    private var scheduleCell = UITableViewCell()

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
    
//    func setDelegate(_ delegate: TrackerNavigationViewProtocol) {
//        self.delegateTrackerInNewHabitVC = delegate
//    }
    
    func dafaultFields() {
        trackerNameTextfield.text = ""
        categoryCell.detailTextLabel?.text = buttonNameArray[0].0
        scheduleCell.detailTextLabel?.text = buttonNameArray[0].1
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
        print("Create habit in NewHabitVC")
        guard let delegateTrackerInNewHabitVC else {
            print("no delegate")
            return
        }
        guard let trackerText = trackerNameTextfield.text else { return }
//        print(daysToSend)
        delegateTrackerInNewHabitVC.getDelegateTracker().addingTrackerOnScreen(trackerName: trackerText, trackerCategory: defaultHeader, dateArray: daysToSend)
        self.dismiss(animated: true)
    }
    
    var defaultHeader = "Трекеры по умолчанию"
    
    @objc func editingTrackerName(_ sender: UITextField) {
        guard let text = sender.text else { return }
//        print(text)
        if text.isEmpty == true || text.count > 38 {
            createButton.isEnabled = false
            createButton.backgroundColor = .ypGray
        } else {
            createButton.isEnabled = true
            createButton.backgroundColor = .ypBlack
            categoryCell.detailTextLabel?.text = defaultHeader
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
    
    
    private func intsToDaysOfWeek(dayArray: [Int]) -> String {
        if dayArray.count == 7 {
            daysToSend = dayArray.compactMap { ScheduledDays(rawValue: $0) }
            return "Каждый день"
        }
        let russianLocale = Locale(identifier: "ru-RU")
        var russianCalendar = Calendar.current
        russianCalendar.locale = russianLocale
                
        let weekDaySymbols = russianLocale.calendar.shortWeekdaySymbols
//        print(weekDaySymbols)
        
//        var daysToSend = ScheduledDays(rawValue: 1)!
        daysToSend = dayArray.compactMap { ScheduledDays(rawValue: $0) }
//        print(daysToSend)
//        print(dayArray)
        var dayNames = dayArray.compactMap { index in
            index >= 0 && index < weekDaySymbols.count ? weekDaySymbols[index] : nil
        }
//        print(dayNames)
        if dayArray.first == 0 {
            let tempDay = dayNames.remove(at: 0)
//            print(tempDay, dayNames.count)
            dayNames.insert(tempDay, at: (dayNames.count))
        }
//        print(dayNames)
        return dayNames.joined(separator: ", ")
    }
    
}

extension NewHabitVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 1 && cell.detailTextLabel?.text != "Дни недели" {
            cell.detailTextLabel?.text = "Дни недели"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75 //.remainderReportingOverflow(dividingBy: <#T##Int#>)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
//            print("calling category dialog")
            let categoryVC = CategoryVC()
            navigationController?.pushViewController(categoryVC, animated: true)
        } else {
//            print("calling schedule dialog")
            let scheduleVC = ScheduleVC()
            navigationController?.pushViewController(scheduleVC, animated: true)
            let curCell = tableView.cellForRow(at: indexPath)
            curCell?.detailTextLabel?.text = buttonNameArray[indexPath.row].1
            scheduleVC.tappedReady = { [weak self] (wdArray) -> Void in
                guard let self else { return }
//                print("wdArray in NewbitVC", wdArray)
                let daysString = intsToDaysOfWeek(dayArray: wdArray)
                let curCell = tableView.cellForRow(at: indexPath)
                curCell?.detailTextLabel?.text = daysString
            }
            tableView.reloadData()
        }
//        tableView.reloadData()
    }
}

extension NewHabitVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell") //as? HabitTableViewCell
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "tableCell") //as? HabitTableViewCell
//        guard let cell else { return UITableViewCell()}
        if indexPath.row == 0 {
            categoryCell = cell
        } else {
            scheduleCell = cell
        }
        cell.textLabel?.text = buttonNameArray[indexPath.row].0
        cell.detailTextLabel?.text = buttonNameArray[indexPath.row].1
        cell.detailTextLabel?.textColor = .ypGray
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.detailTextLabel?.font = .systemFont(ofSize: 17)
//        cell.layer.borderColor = UIColor.red.cgColor
//        buttonTableView.separatorStyle = .singleLine

        cell.backgroundColor = .ypBackgroundDay
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    

}

