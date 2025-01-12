//
//  TrackerCreateVC.swift
//  Tracker
//
//  Created by Valery Zvonarev on 12.11.2024.
//

import UIKit

final class TrackerCreateVC: UIViewController, TrackerCreateVCProtocol {
    
    private let newHabitVC = NewHabitVC()
    private let newEventVC = NewEventVC()
    weak var delegateTracker: TrackerNavigationViewProtocol?
    
    private lazy var habitButton: UIButton = {
        let habitButton = UIButton()
        habitButton.backgroundColor = TrackerColors.backgroundButtonColor
        habitButton.layer.cornerRadius = 16
        habitButton.setTitle(habitButtonName, for: .normal)
        habitButton.setTitleColor(TrackerColors.buttonTintColor, for: .normal)
//        habitButton.titleLabel?.textColor = TrackerColors.buttonTintColor
        habitButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        habitButton.addTarget(self, action: #selector(habitCreation), for: .touchUpInside)
        return habitButton
    }()

    private lazy var eventButton: UIButton = {
        let eventButton = UIButton()
        eventButton.layer.cornerRadius = 16
        eventButton.backgroundColor = TrackerColors.backgroundButtonColor
        eventButton.setTitle(eventButtonName, for: .normal)
        eventButton.setTitleColor(TrackerColors.buttonTintColor, for: .normal)
//        eventButton.titleLabel?.textColor = TrackerColors.backgroundButtonColor
        eventButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        eventButton.addTarget(self, action: #selector(eventCreation), for: .touchUpInside)
        return eventButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = createTrackerTitle
//        navigationController?.navigationBar.tintColor = .ypBlack
        newHabitVC.delegateTrackerInNewHabitVC = self
        viewSetup()
    }
    
    func getDelegateTracker() -> TrackerNavigationViewProtocol {
        return delegateTracker!
    }
    
    private func viewSetup() {
        view.backgroundColor = TrackerColors.viewBackgroundColor
        let buttonSet = [habitButton, eventButton]
        let stackView = UIStackView(arrangedSubviews: buttonSet)
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        let elementArray = [stackView]
        elementArray.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.heightAnchor.constraint(equalToConstant: 136)
        ])
    }
    
    @objc private func habitCreation() {
        newHabitVC.defaultFields()
//        newHabitVC.isTrackerFlag = true
        navigationController?.pushViewController(newHabitVC, animated: true)
    }

    @objc private func eventCreation() {
        newEventVC.defaultFields()
        navigationController?.pushViewController(newEventVC, animated: true)
    }
}
