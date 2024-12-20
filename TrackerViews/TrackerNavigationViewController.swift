//
//  TrackerNavigationViewController.swift
//  Tracker
//
//  Created by Valery Zvonarev on 03.11.2024.
//

import UIKit

struct Tracker {
    let id: UUID?
    let name: String?
    let emojiPic: String?
    let color: UIColor?
    let schedule: [ScheduledDays]
}

enum ScheduledDays: Int {
    case Mon = 1
    case Tue = 2
    case Wed = 3
    case Thu = 4
    case Fri = 5
    case Sat = 6
    case Sun = 0
}

struct TrackerCategory {
    let title: String?
    var trackerArray = [Tracker?]()
}

struct TrackerRecord {
    let id: UUID
    let dateExecuted: String
}

struct GeometricParams {
    let leftInset: CGFloat
    let rightInset: CGFloat
    let cellSpacing: CGFloat
    
    init(leftInset: CGFloat, rightInset: CGFloat, cellSpacing: CGFloat) {
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.cellSpacing = cellSpacing
    }
}

final class TrackerNavigationViewController: UIViewController, TrackerNavigationViewProtocol {
    
    private var categories = [TrackerCategory]()
    private var trackerCategoryDefault = TrackerCategory(title: "Трекеры по умолчанию")
    private var completedTrackers = [TrackerRecord]()
    private var trackersFilteredByWeekdays = [Tracker]()
    private var trackersToDisplay = [Tracker]()
    private var allTrackers = [Tracker]()
    private let trackerColorSet = [UIColor.ypDarkRed, UIColor.ypDarkBlue, UIColor.ypDarkGreen]
    private let params = GeometricParams(leftInset: 16, rightInset: 16, cellSpacing: 10)
    
    private var dateField = UITextField()
    private let localeID = Locale.preferredLanguages.first
    private var currentDate = Date()
    private var selectedDate = Date()
    private let createTracker = TrackerCreateVC()
    
    private let emojiArray = [ "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🥭", "🍎", "🍏", "🍐", "🍒", "🍓", "🫐", "🥝", "🍅", "🫒", "🥥", "🥑", "🍆", "🥔", "🥕", "🌽", "🌶️", "🫑", "🥒", "🥬", "🥦", "🧄", "🧅", "🍄"]

// MARK: mock trackers and mock tracker creation function
//    var mockTracker1 = Tracker(id: 1, name: "test tracker 1", emojiPic: "🍇", color: .ypGreen , schedule: [.Mon, .Sun])
//    var mockTracker2 = Tracker(id: 2, name: "test tracker 2", emojiPic: "🍈", color: .red, schedule: [.Mon, .Thu, .Sun])
    
//    func tempMockTrackerSetup() {
//        var colorNum = Int.random(in: 0..<3) // Number to take UIColor ffrom arrays
//        var emojiNum = Int.random(in: 0..<emojiArray.count)
//        mockTracker1 = Tracker(id: 1, name: "test tracker 1", emojiPic: emojiArray[emojiNum], color: trackerColorSet[colorNum] , schedule: [.Mon, .Sun])
//        colorNum = Int.random(in: 0..<3) // Number to take UIColor ffrom arrays
//        emojiNum = Int.random(in: 0..<emojiArray.count)
//        mockTracker2 = Tracker(id: 2, name: "test tracker 2", emojiPic: emojiArray[emojiNum], color: trackerColorSet[colorNum], schedule: [.Thu, .Sun])
//        allTrackers.append(mockTracker1)
//        allTrackers.append(mockTracker2)
//        categories[0].trackerArray.append(mockTracker1)
//        categories[0].trackerArray.append(mockTracker2)
////        print(categories) //, categories[0])
//    }
    
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
    
    private lazy var addHabitButton: UIBarButtonItem = {
        let addHabitButton = UIBarButtonItem(image: UIImage.plusButton, style: .done, target: self, action: #selector(leftAddHabit))
        return addHabitButton
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru-RU")
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trackerCategoriesSetup()
//        tempMockTrackerSetup() // calling mockTracker setup function
        createTracker.delegateTracker = self
        setupNaviVC()
        naviBarSetup()
        showingTrackersForCurrentDate()
    }

// MARK: Public functions
    func addingTrackerOnScreen(trackerName: String, trackerCategory: String, dateArray: [ScheduledDays]) {
        let idNum = UUID()
        let colorNum = Int.random(in: 0..<3)
        let emojiNum = Int.random(in: 0..<emojiArray.count)
        let addedTracker = Tracker(id: idNum, name: trackerName, emojiPic: emojiArray[emojiNum], color: trackerColorSet[colorNum], schedule: dateArray)
        allTrackers.append(addedTracker)
        let nameForCategory = categoryHeaderCheck(categoryTitle: trackerCategory)
        nameForCategory == "" ? categories[0].trackerArray.append(addedTracker) : print("adding new category")
        showingTrackersForSelectedDate()
        arrayToUse()
        collectionView.reloadData()
    }
    
    // заглушка под метод проверки наличия категории
    func categoryHeaderCheck(categoryTitle: String) -> String {
//        categories.forEach { categoryTitle in
//            print(categoryTitle)
//        }
        return ""
    }

// MARK: Private functions
    private func trackerCategoriesSetup() {
        categories.append(trackerCategoryDefault)
    }
    
    private func setupNaviVC() {
        emptyTrackerSetup()
        if allTrackers.isEmpty {
            collectionViewSetup()
        } else {
            imageView.isHidden.toggle()
            initLogo.isHidden.toggle()
            collectionViewSetup()
        }
        collectionView.reloadData()
    }
    
    private func emptyTrackerSetup() {
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
        view.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SupplementaryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
    }
    
    private func naviBarSetup() {
        addHabitButton.tintColor = .black
        self.navigationItem.leftBarButtonItem = addHabitButton
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchBar
        let myDateField = UIBarButtonItem(customView: datePicker)
        
        dateField.backgroundColor = .lightGray
        dateField.tintColor = .black
        dateField.inputView = datePicker
        
// MARK: Locale set to RU. Can be switched to current settings-dependent
        //        guard let localeID else { return }
        //        datePicker.locale = Locale(identifier: localeID)
        datePicker.locale = Locale(identifier: "ru-RU")
        navigationItem.rightBarButtonItem = myDateField
        
    }
    
    private func showingTrackersForCurrentDate() {
        let curDayOfWeek = Calendar.current.component(.weekday, from: currentDate)
        filteringTrackers(curDayOfWeek: curDayOfWeek - 1)
    }
    
    private func showingTrackersForSelectedDate() {
        let curDayOfWeek = Calendar.current.component(.weekday, from: selectedDate)
        filteringTrackers(curDayOfWeek: curDayOfWeek - 1)
    }
    
    private func filteringTrackers(curDayOfWeek: Int) {
        trackersFilteredByWeekdays = allTrackers.filter {
            let arr = $0.schedule
            for elem in arr {
                if elem.rawValue == curDayOfWeek {
                    return true
                }
            }
            return false
        }
    }
    
    private func togglingCompletedTrackers(date: Date, trackerId: UUID) {
        let trackerDate = getDateFromDatePicker(date: date)
        let trackerToHandle = TrackerRecord(id: trackerId, dateExecuted: trackerDate)

        if !checkDateInCompletedTrackers(tracker: trackerToHandle) {
            completedTrackers.append(trackerToHandle)
        } else {
            let num = completedTrackers.firstIndex(where: {$0.dateExecuted == trackerToHandle.dateExecuted && $0.id == trackerToHandle.id})
            guard let num else {return}
            completedTrackers.remove(at: num)
        }
    }
    
    private func checkingCompletedTrackers(trackerId: UUID) -> Bool {
        let trackerDate = getDateFromDatePicker(date: selectedDate)
        let trackerToCheck = TrackerRecord(id: trackerId, dateExecuted: trackerDate)
        return checkDateInCompletedTrackers(tracker: trackerToCheck)
    }
    
    private func checkDateInCompletedTrackers(tracker: TrackerRecord) -> Bool {
        let res = completedTrackers.contains { $0.dateExecuted == tracker.dateExecuted && $0.id == tracker.id }
        return res
    }

// MARK: @objc functions
    @objc func dateChanged(sender: UIDatePicker) {
        selectedDate = sender.date
        let curDayOfWeek = sender.calendar.component(.weekday, from: selectedDate) - 1
        filteringTrackers(curDayOfWeek: curDayOfWeek)
        arrayToUse()
        if trackersToDisplay.isEmpty {
            imageView.isHidden = false
            initLogo.isHidden = false
        } else {
            imageView.isHidden = true
            initLogo.isHidden = true
        }
        collectionView.reloadData()
    }
    
    private func getDateFromDatePicker(date: Date) -> String {
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: date)
    }
    
    private func arrayToUse() {
        trackersToDisplay = trackersFilteredByWeekdays
        if trackersToDisplay.count == 0 {
            imageView.isHidden = false
            initLogo.isHidden = false
        } else {
            imageView.isHidden = true
            initLogo.isHidden = true
        }
    }

    @objc func leftAddHabit() {
        let navigationController = UINavigationController(rootViewController: createTracker)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension TrackerNavigationViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        arrayToUse()
        return trackersToDisplay.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerCellViewController
        guard let cell,
              let id = trackersToDisplay[indexPath.item].id,
              let color = trackersToDisplay[indexPath.item].color,
              let emoji = trackersToDisplay[indexPath.item].emojiPic,
              let text = trackersToDisplay[indexPath.item].name else { return UICollectionViewCell() }
        cell.layer.cornerRadius = 10
        var colorNumber: Int = 0
        for indeхColor in 0..<trackerColorSet.count {
            if trackerColorSet[indeхColor] == color {
                colorNumber = indeхColor
            }
        }
        changeCellButton(cell: cell, trackerId: id)
        trackerCompletedDaysCount(cell: cell, trackerId: id)
        cell.setColorsInCell(color: colorNumber)
        cell.setEmoji(emoji: emoji)
        cell.setLabelText(text: text)
        cell.tintColor = .clear
        cell.tapped = { [weak self] in
            guard let self else { return }
            self.togglingCompletedTrackers(date: selectedDate, trackerId: id)
            changeCellButton(cell: cell, trackerId: id)
            trackerCompletedDaysCount(cell: cell, trackerId: id)
        }
        if !(Calendar.current.isDate(selectedDate, inSameDayAs: currentDate)) && selectedDate > currentDate {
            cell.disablingPlusButton()
            return cell
        }
        cell.enablingPlusButton()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let id = "header"
        let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! SupplementaryHeaderView
        let headerText = categories[0].title
        supplementaryView.headerLabel.text = headerText
        supplementaryView.systemLayoutSizeFitting(CGSize(width: supplementaryView.frame.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
        if trackersToDisplay.isEmpty == true {
            supplementaryView.isHidden = true
        } else {
            supplementaryView.isHidden = false
        }
        return supplementaryView
    }
    
    private func trackerCompletedDaysCount(cell: TrackerCellViewController, trackerId: UUID) {
        var counter = 0
        for element in completedTrackers {
            if element.id == trackerId {
                counter += 1
            }
        }
        cell.setDayLabelText(days: counter)
    }
    
    private func changeCellButton(cell: TrackerCellViewController, trackerId: UUID) {
        checkingCompletedTrackers(trackerId: trackerId) ? cell.setButtonSign(isPlusSignOnFlag: true) : cell.setButtonSign(isPlusSignOnFlag: false)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackerNavigationViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let curWidth = collectionView.frame.width / 2
        let curHeight = curWidth / 1.12
        return CGSize(width: curWidth - 7, height: curHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 18)
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

