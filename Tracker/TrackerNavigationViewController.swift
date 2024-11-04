//
//  TrackerNavigationViewController.swift
//  Tracker
//
//  Created by Valery Zvonarev on 03.11.2024.
//

import UIKit

final class TrackerNavigationViewController: UIViewController {
        
    private lazy var searchBar: UISearchController = {
        var searchField = UISearchController()
        searchField.searchBar.placeholder = "Поиск"
        searchField.searchResultsUpdater = self
        searchField.obscuresBackgroundDuringPresentation = false
        searchField.hidesNavigationBarDuringPresentation = false
        searchField.searchBar.tintColor = .black
        searchField.searchBar.delegate = self
        searchField.delegate = self
        return searchField
    }()
    
    private var dateField = UITextField()
    private let datePicker = UIDatePicker()
    private let localeID = Locale.preferredLanguages.first

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNaviVC()
        checkFunction()
    }
    
    private func setupNaviVC() {
        
//        let navigationBar = self.navigationController?.navigationBar
//        self.navigationBar.barStyle = UIBarStyle.black
        
        let image = UIImage.flyingStar
        let imageView = UIImageView(image: image)
        let initLogo = UILabel()
        view.backgroundColor = .white
        initLogo.text = "Что будем отслеживать?"
        initLogo.font = UIFont(name: "SFPro", size: 12)
        initLogo.textColor = .ypBlack
        initLogo.sizeToFit()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        initLogo.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .white
        view.addSubview(imageView)
        view.addSubview(initLogo)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            initLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            initLogo.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8)
        ])
//        let plusHabit = UIBarButtonItem(image: UIImage.plus, style: .plain, target: self, action: #selector(addHabit))
//        self.navigationItem.rightBarButtonItem = plusHabit
//        let rightButton = UIBarButtonItem(title: "Right",
//                                          style: .plain,
//                                          target: self,
//                                          action: #selector(rightAddHabit))
//        navigationItem.rightBarButtonItems = [rightButton]

    }
    
    func checkFunction() {
        let addHabitButton = UIBarButtonItem(image: UIImage.plusButton, style: .done, target: self, action: #selector(leftAddHabit))
        addHabitButton.tintColor = .black
        self.navigationItem.leftBarButtonItem = addHabitButton
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchBar
//        let myTextField = UIBarButtonItem(customView: dateField)
//        let myTextField = UIBarButtonItem(customView: <#T##UIView#>)
        let myDateField = UIBarButtonItem(customView: datePicker)
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd.MM.yyyy"
//        datePicker.textInputMode = . formatter.string(from: datePicker.date)
//        myTextField.title = formatter.string(from: datePicker.date)
//        (title: "Date",
//                                          style: .plain,
//                                          target: self,
//                                          action: nil)
        dateField.backgroundColor = .lightGray
        dateField.tintColor = .black
        dateField.inputView = datePicker
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        guard let localeID else { return }
        datePicker.locale = Locale(identifier: localeID)
        navigationItem.rightBarButtonItem = myDateField
//        datePicker.calendar.
//        dateField.text = "Date"
//        getDateFromDatePicker()
//        myTextField.customView?.inputView = datePicker
//        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureDone))
//        self.view.addGestureRecognizer(tapGesture)
//        let searchLine = UISearchBar()
//        self.navigationItem.searchController?.searchBar
//        let rightButton = UIBarButtonItem(title: "Right", style: .done, target: self, action: #selector(rightAddHabit))
//        trackerNaviVC.navigationItem.title = "Tracker"
//        trackerNaviVC.navigationItem.rightBarButtonItems = [rightButton]
//        trackerNaviVC.navigationItem.leftBarButtonItem = addHabitButton
    }
    
    @objc func tapGestureDone() {
        print("in tapGestureDone")
        view.endEditing(true)
    }
    
    @objc func dateChanged() {
        getDateFromDatePicker()
        datePicker.endEditing(true)
    }
    
    func getDateFromDatePicker() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
//        my Field.text = formatter.string(from: datePicker.date)
        
//        if dateField.text == "" {
//            dateField.text = formatter.string(from: Date())
//        } else {
//            dateField.text = formatter.string(from: datePicker.date)
//        }
//        dateField.sizeToFit()
    }
    
    @objc func rightAddHabit() {
        print("adding right habit")
    }
    
    @objc func leftAddHabit() {
        print("adding habit")
    }
}

extension TrackerNavigationViewController: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
    
}
