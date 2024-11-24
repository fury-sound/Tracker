//
//  TrackerCreateVC.swift
//  Tracker
//
//  Created by Valery Zvonarev on 12.11.2024.
//

import UIKit

final class TrackerCreateVC: UIViewController, TrackerCreateVCProtocol {
    
//    private lazy var titleLabel: UILabel = {
//        let titleLabel = UILabel()
//        titleLabel.backgroundColor = .clear
//        titleLabel.text = "Создание трекера"
//        titleLabel.textAlignment = .center
//        titleLabel.font = UIFont(name: "SFPro", size: 16)
//        return titleLabel
//    }()
        
    private lazy var habitButton: UIButton = {
        let habitButton = UIButton()
        habitButton.backgroundColor = .ypBlack
        habitButton.layer.cornerRadius = 16
        habitButton.setTitle("Привычка", for: .normal)
        habitButton.titleLabel?.textColor = .ypWhite
        habitButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        habitButton.addTarget(self, action: #selector(habitCreation), for: .touchUpInside)
        return habitButton
    }()

    private lazy var eventButton: UIButton = {
        let eventButton = UIButton()
        eventButton.layer.cornerRadius = 16
        eventButton.backgroundColor = .ypBlack
        eventButton.setTitle("Нерегулярное событие", for: .normal)
        eventButton.titleLabel?.textColor = .ypWhite
        eventButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        eventButton.addTarget(self, action: #selector(eventCreation), for: .touchUpInside)
        return eventButton
    }()
    
    let newHabitVC = NewHabitVC()
    weak var delegateTracker: TrackerNavigationViewProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Создание трекера"
        navigationController?.navigationBar.tintColor = .ypBlack
        newHabitVC.delegateTrackerInNewHabitVC = self
        viewSetup()
    }
    
    func getDelegateTracker() -> TrackerNavigationViewProtocol {
        return delegateTracker!
    }
    
    private func viewSetup() {
        view.backgroundColor = .ypWhite
        let buttonSet = [habitButton, eventButton]
        let stackView = UIStackView(arrangedSubviews: buttonSet)
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        
//        let elementArray = [titleLabel, stackView]
        let elementArray = [stackView]
        elementArray.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        NSLayoutConstraint.activate([
//            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 78),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.heightAnchor.constraint(equalToConstant: 136)
        ])
        
    }
    
    
    @objc func habitCreation() {
//        print("habit creation")
        newHabitVC.dafaultFields()
        navigationController?.pushViewController(newHabitVC, animated: true)
//        let navigationController = UINavigationController(rootViewController: newHabitVC)
//        navigationController.modalPresentationStyle = .formSheet
//        present(navigationController, animated: true)
    }

    @objc func eventCreation() {
//        print("event creation")
        alertForReviewer()
        
//        delegateTracker?.addingTrackerOnScreen()
    }
    
    private func alertForReviewer() {
        let alert = UIAlertController(title: "Нерегулярное событие\n",
                                              message: "Уважаемый ревьювер)))\n" +
                                              "В задание 14-го спринта функционал данной кнопки не предполагает быть реализованным именно в 14-ом спринте," +
                                              " он будет реализован в 15-ом спринте!\n Честное слово!!!)))\n 😉",
                                              preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                alert.addAction(action)
                present(alert, animated: true)
    }
    
}
