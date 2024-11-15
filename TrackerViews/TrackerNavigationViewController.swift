//
//  TrackerNavigationViewController.swift
//  Tracker
//
//  Created by Valery Zvonarev on 03.11.2024.
//

import UIKit

struct Tracker {
    let id: UInt?
    let name: String?
    let emojiPic: String?
    let color: UIColor?
    let schedule: [ScheduledDays]
}

enum ScheduledDays {
    case Mon
    case Tue
    case Wed
    case Thu
    case Fri
    case Sat
    case Sun
}

struct TrackerCategory {
    let title: String?
    let trackerArray = [Tracker?]()
}

struct TrackerRecord {
    let id: UInt
    let dateExecuted: Date
}

struct GeometricParams {
//    let cellCount: Int
    let leftInset: CGFloat
    let rightInset: CGFloat
    let cellSpacing: CGFloat
//    let paddingWidth: CGFloat
    
//    init(cellCount: Int, leftInset: CGFloat, rightInset: CGFloat, cellSpacing: CGFloat) {
    init(leftInset: CGFloat, rightInset: CGFloat, cellSpacing: CGFloat) {
//        self.cellCount = cellCount
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.cellSpacing = cellSpacing
//        self.paddingWidth = leftInset + rightInset + CGFloat((cellCount - 1)) * cellSpacing
    }
}

final class TrackerNavigationViewController: UIViewController {
        
    var categories = [TrackerCategory]()
    var completedTrackers = [TrackerRecord]()
    
    var mockTracker1 = Tracker(id: 1, name: "test tracker 1", emojiPic: "🍇", color: .ypGreen , schedule: [.Mon, .Fri])
    var mockTracker2 = Tracker(id: 2, name: "test tracker 2", emojiPic: "🍈", color: .red, schedule: [.Thu, .Wed])
    var mockTrackers = [Tracker?]()
    
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
    
    private lazy var collectionView: UICollectionView = {
//        layout.scrollDirection = .vertical
//        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        collectionView.register(TrackerCellViewController.self, forCellWithReuseIdentifier: "cell")
        return collectionView
    }()
    
    private lazy var imageView: UIImageView = {
        let image = UIImage.flyingStar
        let imageView = UIImageView(image: image)
        imageView.backgroundColor = .clear
        return imageView
    }()

    private lazy var initLogo: UILabel = {
        let initLogo = UILabel()
        initLogo.backgroundColor = .clear
        initLogo.text = "Что будем отслеживать?"
        initLogo.font = .systemFont(ofSize: 12, weight: .medium)
        initLogo.textColor = .ypBlack
        initLogo.sizeToFit()
        return initLogo
    }()
    
    
    let params = GeometricParams(leftInset: 16,
                                 rightInset: 16,
                                 cellSpacing: 10)
    

    
    private var dateField = UITextField()
    private let datePicker = UIDatePicker()
    private let localeID = Locale.preferredLanguages.first

    override func viewDidLoad() {
        super.viewDidLoad()
//        mockTrackers.append(mockTracker1)
//        mockTrackers.append(mockTracker2)
        setupNaviVC()
        naviBarSetup()
    }
    
    private func setupNaviVC() {
//        let navigationBar = self.navigationController?.navigationBar
//        self.navigationBar.barStyle = UIBarStyle.black
        if mockTrackers.isEmpty {
            emptyTrackerSetup()
//            imageView.isHidden = false
//            initLogo.isHidden = false
        } else {
            collectionViewSetup()
        }
    }
    
    private func emptyTrackerSetup() {
//        let image = UIImage.flyingStar
//        let imageView = UIImageView(image: image)
//        let initLogo = UILabel()
        view.backgroundColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        initLogo.translatesAutoresizingMaskIntoConstraints = false
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
    }
    
    private func collectionViewSetup() {
        view.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
//        layout.itemSize = collectionView(width: 100, height: 50)
//        layout.itemSize = CGSize(width: emojiCollectionView.frame.width / 2, height: 50)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func naviBarSetup() {
        let addHabitButton = UIBarButtonItem(image: UIImage.plusButton, style: .done, target: self, action: #selector(leftAddHabit))
        addHabitButton.tintColor = .black
        self.navigationItem.leftBarButtonItem = addHabitButton
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchBar
        let myDateField = UIBarButtonItem(customView: datePicker)

        dateField.backgroundColor = .lightGray
        dateField.tintColor = .black
        dateField.inputView = datePicker
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        guard let localeID else { return }
        datePicker.locale = Locale(identifier: localeID)
        navigationItem.rightBarButtonItem = myDateField

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
    }
    
    @objc func rightAddHabit() {
        print("adding right habit")
    }
    
    @objc func leftAddHabit() {
        print("adding habit")
        
        let createTracker = TrackerCreateVC()
        let navigationController = UINavigationController(rootViewController: createTracker)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true)
        
        if mockTrackers.isEmpty {
            imageView.isHidden = true
            initLogo.isHidden = true
            collectionViewSetup()
        }
//        mockTrackers.append(mockTracker1)
//        collectionView.reloadData()
//        let elementToAddIndex = 0 //mockTrackers.count - 1
//        collectionView.performBatchUpdates {
//            collectionView.insertItems(at: [IndexPath(item: elementToAddIndex, section: 0)])
//        }
//        print(mockTrackers)
    }
}

// MARK: - UICollectionViewDataSource

extension TrackerNavigationViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mockTrackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerCellViewController
        guard let cell,
              let color = mockTrackers[indexPath.item]?.color,
                let emoji = mockTrackers[indexPath.item]?.emojiPic,
                let text = mockTrackers[indexPath.item]?.name else { return UICollectionViewCell() }
        cell.layer.cornerRadius = 10
//        guard let color = mockTrackers[indexPath.item].color, let emoji = mockTrackers[indexPath.item].emojiPic, let text = mockTrackers[indexPath.item].name else { return UICollectionViewCell() }
        cell.setTrackerColor(color: color)
        cell.setEmoji(emoji: emoji)
        cell.setLabelText(text: text)
//        cell.textLabel.textColor = .ypWhite
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackerNavigationViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let curWidth = collectionView.frame.width / 2
        let curHeight = curWidth / 1.9
//        return CGSize(width: curWidth - (params.leftInset + params.rightInset), height: curHeight)
        return CGSize(width: 167, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: params.leftInset, bottom: 10, right: params.rightInset)
    }
    
}

//MARK: - UICollectionViewDelegate

extension TrackerCellViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension TrackerNavigationViewController: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
    
}
