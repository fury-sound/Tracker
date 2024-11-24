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
        navigationItem.setHidesBackButton(true, animated: true)
    }
    

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
        let buttonSet = [cancelButton, createButton]
        let stackView = UIStackView(arrangedSubviews: buttonSet)
        stackView.backgroundColor = .clear
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        
        let elementArray = [trackerNameTextfield, buttonTableView, stackView]
        elementArray.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        NSLayoutConstraint.activate([
            trackerNameTextfield.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerNameTextfield.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerNameTextfield.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            trackerNameTextfield.heightAnchor.constraint(equalToConstant: 75),
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

    
    @objc func cancelHabitCreation() {
        self.dismiss(animated: true)
    }

    @objc func createHabit() {
        guard let delegateTrackerInNewHabitVC else {
            debugPrint("no delegate")
            return
        }
        guard let trackerText = trackerNameTextfield.text else { return }
        delegateTrackerInNewHabitVC.getDelegateTracker().addingTrackerOnScreen(trackerName: trackerText, trackerCategory: defaultHeader, dateArray: daysToSend)
        self.dismiss(animated: true)
    }
    
    var defaultHeader = "Трекеры по умолчанию"
    
    @objc func editingTrackerName(_ sender: UITextField) {
        guard let text = sender.text else { return }
        if text.isEmpty == true || text.count > 38 {
            createButton.isEnabled = false
            createButton.backgroundColor = .ypGray
        } else {
            createButton.isEnabled = true
            createButton.backgroundColor = .ypBlack
            categoryCell.detailTextLabel?.text = defaultHeader
        }
    }
    
    private func intsToDaysOfWeek(dayArray: [Int]) -> String {
        if dayArray.count == 7 {
            daysToSend = dayArray.compactMap { ScheduledDays(rawValue: $0) }
            return "Каждый день"
        }
        let russianLocale = Locale(identifier: "ru-RU")
        var russianCalendar = Calendar.current
        russianCalendar.locale = russianLocale
        let weekDaySymbols = russianLocale.calendar.shortWeekdaySymbols
        
        daysToSend = dayArray.compactMap { ScheduledDays(rawValue: $0) }
        var dayNames = dayArray.compactMap { index in
            index >= 0 && index < weekDaySymbols.count ? weekDaySymbols[index] : nil
        }
        if dayArray.first == 0 {
            let tempDay = dayNames.remove(at: 0)
            dayNames.insert(tempDay, at: (dayNames.count))
        }
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
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let categoryVC = CategoryVC()
            navigationController?.pushViewController(categoryVC, animated: true)
        } else {
            let scheduleVC = ScheduleVC()
            navigationController?.pushViewController(scheduleVC, animated: true)
            let curCell = tableView.cellForRow(at: indexPath)
            curCell?.detailTextLabel?.text = buttonNameArray[indexPath.row].1
            scheduleVC.tappedReady = { [weak self] (wdArray) -> Void in
                guard let self else { return }
                let daysString = intsToDaysOfWeek(dayArray: wdArray)
                let curCell = tableView.cellForRow(at: indexPath)
                curCell?.detailTextLabel?.text = daysString
            }
            tableView.reloadData()
        }
    }
}

extension NewHabitVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "tableCell")
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
        cell.backgroundColor = .ypBackgroundDay
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}

extension NewHabitVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        trackerNameTextfield.resignFirstResponder()
        return true
    }
}

