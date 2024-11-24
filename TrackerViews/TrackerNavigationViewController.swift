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
//        tempMockTrackerSetup()
        createTracker.delegateTracker = self
        setupNaviVC()
        naviBarSetup()
        showingTrackersForCurrentDate()
    }
    
    private func trackerCategoriesSetup() {
//        print("1", categories)
        categories.append(trackerCategoryDefault)
//        print("2", categories)
    }
    
    private func setupNaviVC() {
        //        let navigationBar = self.navigationController?.navigationBar
        //        self.navigationBar.barStyle = UIBarStyle.black
        //        mockTrackers.append(mockTracker1)
        emptyTrackerSetup()
        if allTrackers.isEmpty {
            collectionViewSetup()
            //            imageView.isHidden = false
            //            initLogo.isHidden = false
        } else {
            imageView.isHidden.toggle()
            initLogo.isHidden.toggle()
            collectionViewSetup()
        }
        collectionView.reloadData()
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
        view.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        //        layout.itemSize = collectionView(width: 100, height: 50)
        //        layout.itemSize = CGSize(width: emojiCollectionView.frame.width / 2, height: 50)
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
    
//    @objc func tapGestureDone() {
//        print("in tapGestureDone")
//        view.endEditing(true)
//    }
    
    private func showingTrackersForCurrentDate() {
        let curDayOfWeek = Calendar.current.component(.weekday, from: currentDate)
//        print("in showingTrackersForCurrentDate", curDayOfWeek)
        filteringTrackers(curDayOfWeek: curDayOfWeek - 1)
    }
    
    private func showingTrackersForSelectedDate() {
        let curDayOfWeek = Calendar.current.component(.weekday, from: selectedDate)
//        print("in showingTrackersForCurrentDate", curDayOfWeek)
        filteringTrackers(curDayOfWeek: curDayOfWeek - 1)
    }
    
    private func filteringTrackers(curDayOfWeek: Int) {
        //        let loopVar = $0.schedule.count - 1
        //        for index in loopVar {
        //
        //        }
        trackersFilteredByWeekdays = allTrackers.filter {
            let arr = $0.schedule
//            print(arr)
//                        var count = arr.count
//                        print(arr, count)
            //            if arr.contains()
            for elem in arr {
//                print(elem.rawValue, curDayOfWeek)
                if elem.rawValue == curDayOfWeek {
                    return true
                }
            }
            return false
        }
//        print(filteredTrackersByWeekdays)
    }
    
    
    private func togglingCompletedTrackers(date: Date, trackerId: UUID) {
        let trackerDate = getDateFromDatePicker(date: date)
//        let curDate = getDateFromDatePicker(date: currentDate)
//        let arrayNum = checkDateInCompletedTrackers(date: trackerDate, id: trackerId)
        let trackerToHandle = TrackerRecord(id: trackerId, dateExecuted: trackerDate)
//        if trackerDate > curDate { return }

        if !checkDateInCompletedTrackers(tracker: trackerToHandle) {
            completedTrackers.append(trackerToHandle)
        } else {
            let num = completedTrackers.firstIndex(where: {$0.dateExecuted == trackerToHandle.dateExecuted && $0.id == trackerToHandle.id})
            guard let num else {return}
            completedTrackers.remove(at: num)
        }
//        print(completedTrackers)
//        print(checkDateInCompletedTrackers(tracker: trackerToHandle))
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

    
    @objc func dateChanged(sender: UIDatePicker) {
        //        print("in dateChanged \(#function)")
        selectedDate = sender.date
        let curDayOfWeek = sender.calendar.component(.weekday, from: selectedDate) - 1
//        let setDate = getDateFromDatePicker(date: selectedDate)
//        print(curDayOfWeek, selectedDate, setDate)
//        let curDate = getDateFromDatePicker(date: currentDate)
//        print(sender.calendar.isDate(currentDate, inSameDayAs: selectedDate))
//        print(curDate, setDate)
//        if setDate != curDate {
        filteringTrackers(curDayOfWeek: curDayOfWeek)
//        }
            //            print("in if")
            //            emptyTrackerSetup()
            //            collectionView.removeFromSuperview()
        arrayToUse()
        if trackersToDisplay.isEmpty {
//            print("1")
            imageView.isHidden = false
            initLogo.isHidden = false
//        }
//            collectionView.reloadData()
            //            collectionViewSetup()
        } else {
//            print("in else")
            imageView.isHidden = true
            initLogo.isHidden = true
//            collectionView.reloadData()
        }
//        print("collectionView.color", collectionView.backgroundColor, imageView.isHidden, initLogo.isHidden)
        collectionView.reloadData()
        
        //        print(sender.date)
        //        print(sender.calendar.component(.weekday, from: sender.date))
        //        let wkDate = getDateFromDatePicker(date: sender.date)
        //        let intDayOfWeek = sender.calendar.component(.weekday, from: sender.date)
        //        print(wkDate)
        //        print(ScheduledDays(rawValue: intDayOfWeek))
        //        guard let tracker = mockTrackers[0] else { return }
        //        print(tracker.schedule[0].rawValue, tracker.schedule[1].rawValue)
        //        print(intDayOfWeek == tracker.schedule[0].rawValue, intDayOfWeek == tracker.schedule[1].rawValue)
        //        datePicker.endEditing(true)
    }
    
    func getDateFromDatePicker(date: Date) -> String {
        //        let formatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        //        dateFormatter.setLocalizedDateFormatFromTemplate("EEE")
        return dateFormatter.string(from: date)
    }
    
    func addingTrackerOnScreen(trackerName: String, trackerCategory: String, dateArray: [ScheduledDays]) {
//        print("in addingTrackerOnScreen")
//        print("New tracker:")
        let idNum = UUID()
//        print("UUID", idNum)
        let colorNum = Int.random(in: 0..<3)
        let emojiNum = Int.random(in: 0..<emojiArray.count)
//        let mockTracker = Tracker(id: 3, name: trackerName, emojiPic: "🍇", color: .ypBlue , schedule: [.Tue, .Wed])
        let mockTracker = Tracker(id: idNum, name: trackerName, emojiPic: emojiArray[emojiNum], color: trackerColorSet[colorNum], schedule: dateArray)
//        print(mockTracker)
        allTrackers.append(mockTracker)
        let nameForCategory = categoryHeaderCheck(categoryTitle: trackerCategory)
        nameForCategory == "" ? categories[0].trackerArray.append(mockTracker) : print("adding new category")
//        print("final categories:", categories)

//        trackersToDisplay = allTrackers
//        print(allTrackers)
        showingTrackersForSelectedDate()
        arrayToUse()
        collectionView.reloadData()
    }
    
    private func arrayToUse() {
//        return datePicker.calendar.isDate(currentDate, inSameDayAs: selectedDate) ? allTrackers : filteredTrackersByWeekdays
//        if datePicker.calendar.isDate(currentDate, inSameDayAs: selectedDate) {
//            trackersToDisplay = allTrackers
//        } else {

        trackersToDisplay = trackersFilteredByWeekdays
//        }
//        print("elems in arrayToShow", arrayToShow.count)
        if trackersToDisplay.count == 0 {
            imageView.isHidden = false
            initLogo.isHidden = false
        } else {
            imageView.isHidden = true
            initLogo.isHidden = true
        }
    }
    
//    @objc func rightAddHabit() {
//        print("adding right habit")
//    }
    
    // заглушка под метод проверки наличия категории
    func categoryHeaderCheck(categoryTitle: String) -> String {
//        categories.forEach { categoryTitle in
//            print(categoryTitle)
//        }
        return ""
    }
    
    @objc func leftAddHabit() {
//        print("adding habit")
        
        let navigationController = UINavigationController(rootViewController: createTracker)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true)
        
//        if allTrackers.isEmpty {
//            imageView.isHidden = true
//            initLogo.isHidden = true
//            
//            collectionViewSetup()
//        }
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
        arrayToUse()
        return trackersToDisplay.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        print("filteredTrackersByWeekdays \(filteredTrackersByWeekdays)")
//        let arrayToShow = arrayToUse()
//        if datePicker.calendar.isDate(currentDate, inSameDayAs: selectedDate) {
//            arrayToShow = allTrackers
//        } else {
////            arrayToShow = allTrackers
////            print(indexPath.row, indexPath.item)
//            arrayToShow = filteredTrackersByWeekdays
//        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerCellViewController
        guard let cell,
              let id = trackersToDisplay[indexPath.item].id,
              let color = trackersToDisplay[indexPath.item].color,
              let emoji = trackersToDisplay[indexPath.item].emojiPic,
              let text = trackersToDisplay[indexPath.item].name else { return UICollectionViewCell() }
        cell.layer.cornerRadius = 10
        //        guard let color = mockTrackers[indexPath.item].color, let emoji = mockTrackers[indexPath.item].emojiPic, let text = mockTrackers[indexPath.item].name else { return UICollectionViewCell() }
        //        print("Emoji:", mockTrackers[indexPath.item]?.emojiPic)
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
//            let selectedItem = indexPath.row
//            print("cell number", selectedItem)
            self.togglingCompletedTrackers(date: selectedDate, trackerId: id)
            changeCellButton(cell: cell, trackerId: id)
            trackerCompletedDaysCount(cell: cell, trackerId: id)
        }
        if !(Calendar.current.isDate(selectedDate, inSameDayAs: currentDate)) && selectedDate > currentDate {
//            print(getDateFromDatePicker(date: selectedDate), getDateFromDatePicker(date: currentDate))
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
//        print(supplementaryView.frame.size)
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
//        if checkingCompletedTrackers(trackerId: trackerId) {
////            print("Трекер c id \(trackerId) в Выполненных?", checkingCompletedTrackers(trackerId: trackerId))
//            cell.setButtonSign(isPlusSignOnFlag: true)
//        } else {
////            print("Трекер c id \(trackerId) в Выполненных?", checkingCompletedTrackers(trackerId: trackerId))
//            cell.setButtonSign(isPlusSignOnFlag: false)
//        }
        
        checkingCompletedTrackers(trackerId: trackerId) ? cell.setButtonSign(isPlusSignOnFlag: true) : cell.setButtonSign(isPlusSignOnFlag: false)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackerNavigationViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let curWidth = collectionView.frame.width / 2
        let curHeight = curWidth / 1.12
//        return CGSize(width: curWidth - (params.leftInset + params.rightInset), height: curHeight)
        return CGSize(width: curWidth - 7, height: curHeight)
//        return CGSize(width: 167, height: 148)
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

