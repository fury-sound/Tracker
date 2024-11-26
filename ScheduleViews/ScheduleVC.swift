//
//  ScheduleVC.swift
//  Tracker
//
//  Created by Valery Zvonarev on 14.11.2024.
//

import UIKit

final class ScheduleVC: UIViewController {
       
    private let weekdayArray = ["Понедельник","Вторник","Среда","Четверг","Пятница","Суббота","Воскресенье"]
    private let switchTags = [1,2,3,4,5,6,0]
    private var selectedWeekDates: Set<Int> = []
    var tappedReady: (([Int]) -> Void)?

    private lazy var readyButton: UIButton = {
        let readyButton = UIButton()
        readyButton.layer.cornerRadius = 16
        readyButton.backgroundColor = .ypGray
        readyButton.setTitleColor(.ypWhite, for: .normal)
        readyButton.setTitle("Готово", for: .normal)
        readyButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        readyButton.isEnabled = false
        readyButton.addTarget(self, action: #selector(scheduleAdded), for: .touchUpInside)
        return readyButton
    }()
    
    private lazy var weekdayTableView: UITableView = {
        let weekdayTableView = UITableView()
        weekdayTableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableCell")
        weekdayTableView.backgroundColor = .ypLightGray
        weekdayTableView.isScrollEnabled = false
        weekdayTableView.delegate = self
        weekdayTableView.dataSource = self
        weekdayTableView.separatorStyle = .singleLine
        weekdayTableView.separatorInset.left = 16
        weekdayTableView.separatorInset.right = 16
        weekdayTableView.layer.cornerRadius = 16
        weekdayTableView.layer.masksToBounds = true
        weekdayTableView.clipsToBounds = true
        return weekdayTableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Расписание"
        viewSetup()
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    private func viewSetup() {
        view.backgroundColor = .white
        
        let elementArray = [weekdayTableView, readyButton]
        elementArray.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        NSLayoutConstraint.activate([
            weekdayTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            weekdayTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            weekdayTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            weekdayTableView.heightAnchor.constraint(equalToConstant: 525),
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            readyButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc func scheduleAdded() {
        let wdArray = selectedWeekDates.sorted()
        tappedReady?(wdArray)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func switchOnOff(_ sender: UISwitch) {
        let indexValue = sender.tag
        let isOn = sender.isOn
        if isOn {
            selectedWeekDates.insert(indexValue)
        } else {
            selectedWeekDates.remove(indexValue)
        }
        if selectedWeekDates.isEmpty {
            readyButton.isEnabled = false
            readyButton.backgroundColor = .ypGray
        } else {
            readyButton.isEnabled = true
            readyButton.backgroundColor = .ypBlack
        }
    }
}

extension ScheduleVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("current row \(indexPath.row)")
    }

}

extension ScheduleVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let weekdaySwitch = UISwitch()
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell")
        guard let cell else { return UITableViewCell()}
        cell.textLabel?.text = weekdayArray[indexPath.row]
        cell.backgroundColor = .ypBackgroundDay
        cell.selectionStyle = .none
        cell.isHighlighted = false
        cell.accessoryView = weekdaySwitch
        weekdaySwitch.tag = switchTags[indexPath.row]
        weekdaySwitch.onTintColor = .ypBlue
        weekdaySwitch.addTarget(self, action: #selector(switchOnOff(_ :)), for: .valueChanged)
        return cell
    }
}

