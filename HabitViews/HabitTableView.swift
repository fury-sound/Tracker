//
//  HabitTableView.swift
//  Tracker
//
//  Created by Valery Zvonarev on 14.11.2024.
// OBSOLETE

import UIKit

@objc protocol HabitTableViewProtocol: AnyObject {
    func categoryCreation()
    func scheduleCreation()
}

final class HabitTableView: UITableView {
    
    var habitVC: HabitTableViewProtocol?
    
    private lazy var categoryButton: UIButton = {
        let categoryButton = UIButton()
        categoryButton.backgroundColor = .ypGray
        categoryButton.setTitleColor(.ypBlack, for: .normal)
        categoryButton.setTitle("Категория", for: .normal)
        categoryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        categoryButton.addTarget(self, action: #selector(habitVC?.categoryCreation), for: .touchUpInside)
        categoryButton.frame.size.height = 74
        return categoryButton
    }()

    private lazy var scheduleButton: UIButton = {
        let scheduleButton = UIButton()
        scheduleButton.backgroundColor = .ypGray
        scheduleButton.setTitleColor(.ypBlack, for: .normal)
        scheduleButton.setTitle("Расписание", for: .normal)
        scheduleButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        scheduleButton.addTarget(self, action: #selector(habitVC?.scheduleCreation), for: .touchUpInside)
        scheduleButton.frame.size.height = 74
        return scheduleButton
    }()
}

extension HabitTableView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell") as? HabitTableViewCell
        guard let cell else { return UITableViewCell()}
        cell.backgroundColor = .green
        return cell
    }
    

}
