//
//  TrackerNavigationViewController.swift
//  Tracker
//
//  Created by Valery Zvonarev on 03.11.2024.
//

import UIKit
//import CoreData

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

let EmojiArray = [ "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🥭", "🍎", "🍏", "🍐", "🍒", "🍓", "🫐", "🥝", "🍅", "🫒", "🥥", "🥑", "🍆", "🥔", "🥕", "🌽", "🌶️", "🫑", "🥒", "🥬", "🥦", "🧄", "🧅", "🍄"]

let Colors: [UIColor] = [.ypDarkRed, .ypOrange, .ypDarkBlue, .ypAmethyst, .ypGreen, .ypOrchid, .ypPastelPink, .ypLightBlue, .ypLightGreen, .ypCosmicCobalt, .ypRed, .ypPaleMagentaPink, .ypMacaroniAndCheese, .ypCornflowerBlue, .ypBlueViolet, .ypMediumOrchid, .ypMediumPurple, .ypDarkGreen]

final class TrackerNavigationViewController: UIViewController, TrackerNavigationViewProtocol {
    
    private var categories = [TrackerCategory]()
    private var trackerCategory: TrackerCategory?
    //    private var categories : [String: [Tracker]] = [:]
//    private var trackerCategoryDefault = TrackerCategory(title: "Трекеры по умолчанию")
    private var completedTrackers = [TrackerRecord]()
//    private var trackersFilteredByWeekdays = [Tracker]()
    private var trackersFilteredByWeekdaysDictionary : [String: [Tracker]]? = [:]
//    private var trackersToDisplay = [Tracker]()
//    private var allTrackers = [Tracker]()
    private let trackerColorSet = [UIColor.ypBlack, UIColor.ypDarkRed, UIColor.ypDarkBlue, UIColor.ypDarkGreen]
    private let params = GeometricParams(leftInset: 16, rightInset: 16, cellSpacing: 10)
    
    private var dateField = UITextField()
    private let localeID = Locale.preferredLanguages.first
    private var currentDate = Date()
    private var selectedDate = Date()
    private let createTracker = TrackerCreateVC()
    
    //    private let emojiArray = [ "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🥭", "🍎", "🍏", "🍐", "🍒", "🍓", "🫐", "🥝", "🍅", "🫒", "🥥", "🥑", "🍆", "🥔", "🥕", "🌽", "🌶️", "🫑", "🥒", "🥬", "🥦", "🧄", "🧅", "🍄"]
    
    //    var context: NSManagedObjectContext!
    private let emojiArray = EmojiArray
    private let colorsArray = Colors
    
    //    var context: NSManagedObjectContext {
    //        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //    }
    let trackerStore = TrackerStore()
    let trackerRecordStore = TrackerRecordStore()
    let trackerCategoryStore = TrackerCategoryStore()
    
    // MARK: mock trackers and mock tracker creation function
//    var mockTracker1 = Tracker(id: UUID(), name: "test tracker 1", emojiPic: "🍇", color: .green , schedule: [.Mon, .Sun])
//    var mockTracker2 = Tracker(id: UUID(), name: "test tracker 2", emojiPic: "🍈", color: .red, schedule: [.Mon, .Thu, .Sun])
    
    //    func tempMockTrackerSetup() {
    ////        var colorNum = Int.random(in: 0..<3) // Number to take UIColor ffrom arrays
    //        var emojiNum = Int.random(in: 0..<emojiArray.count)
    //        let mockUUID = UUID()
    ////        mockTracker1 = Tracker(id: mockUUID, name: "test tracker 1", emojiPic: emojiArray[emojiNum], color: trackerColorSet[colorNum] , schedule: [.Mon, .Sun])
    //        mockTracker1 = Tracker(id: mockUUID, name: "test tracker 1", emojiPic: emojiArray[emojiNum], color: trackerColorSet[1] , schedule: [.Mon, .Sun])
    ////        colorNum = Int.random(in: 0..<3) // Number to take UIColor ffrom arrays
    ////        emojiNum = Int.random(in: 0..<emojiArray.count)
    ////        mockTracker2 = Tracker(id: 2, name: "test tracker 2", emojiPic: emojiArray[emojiNum], color: trackerColorSet[colorNum], schedule: [.Thu, .Sun])
    //        allTrackers.append(mockTracker1)
    ////        allTrackers.append(mockTracker2)
    ////        categories[0].trackerArray.append(mockTracker1)
    ////        categories[0].trackerArray.append(mockTracker2)
    //////        print(categories) //, categories[0])
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
        // MARK: temp function calls and variables
//        deleteAllTrackers()
        //        retrieveAllTrackers()
        //        tempMockTrackerSetup() // calling mockTracker setup function
        //        trackerStore.deleteEntities()
        //        var mockTracker2 = trackerStore.retrieveAllTrackers()
        //        allTrackers.append(mockTracker2)
        //        var strWeekDays = trackerStore.scheduleToString(schedule: [.Mon, .Wed])
        //        let lineStr = trackerStore.stringToSchedule(scheduleString: strWeekDays)
        //        print("in viewDidLoad", strWeekDays, lineStr)
        // MARK: end of temp function calls and variables
        
        trackerCategoriesSetup()
        createTracker.delegateTracker = self
        trackerStore.delegateTrackerForNotifications = self
        setupNaviVC()
        naviBarSetup()
        showingTrackersForCurrentDate()
    }
    
    // MARK: Public functions
    
    func addingTrackerOnScreen() {
        showingTrackersForSelectedDate()
        arrayToUse()
        collectionView.reloadData()
    }
    
    // заглушка под метод проверки наличия категории
//    func categoryHeaderCheck(categoryTitle: String) -> String {
//        //        categories.forEach { categoryTitle in
//        //            print(categoryTitle)
//        //        }
//        return ""
//    }
    
    // MARK: Private functions
    
    private func deleteAllTrackers() {
        trackerStore.deleteAllTrackerCoreDataEntities()
        trackerRecordStore.deleteAllTrackerRecordCoreDataEntities()
        trackerCategoryStore.deleteAllTrackerCategoryCoreDataEntities()
    }
    
    private func trackerCategoriesSetup() {
//        mockCategoryAdding()
        trackerStore.countAllEntities()
        trackerStore.retrieveAllTrackers()
//        trackerCategoryStore.countEntities()
//        trackerCategoryStore.retrieveAllTrackerCategories()
    }
    
//    private func mockCategoryAdding() {
//        //        categories["Важное"] = [mockTracker1]
//        //        categories["Важное"]?.append(mockTracker2)
//        var trackerCategory1 = TrackerCategory(title: "Самое важное - 1", trackerArray: [mockTracker1])
//        var trackerCategory2 = TrackerCategory(title: "Самое важное - 2", trackerArray: [mockTracker2])
//        //        trackerCategory.trackerArray.append(mockTracker2)
//        categories.append(trackerCategory1)
//        categories.append(trackerCategory2)
//        print(categories[0].title)
//        print(categories[1].title)
//    }
    
    private func setupNaviVC() {
        emptyTrackerSetup()
//        if ((trackersFilteredByWeekdaysDictionary?.isEmpty) != nil) {
        if categories.isEmpty {
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
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
        navigationController?.navigationBar.backgroundColor = .white
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
        tabBarController?.tabBar.backgroundColor = .white
    }
    
    private func showingTrackersForCurrentDate() {
        let curDayOfWeek = Calendar.current.component(.weekday, from: currentDate)
        filteringTrackers(curDayOfWeek: curDayOfWeek - 1)
    }
    
    private func showingTrackersForSelectedDate() {
        let curDayOfWeek = Calendar.current.component(.weekday, from: selectedDate)
        filteringTrackers(curDayOfWeek: curDayOfWeek - 1)
    }
    
    //TODO: Adapt to filter trackers by weekdays from the CategoryStore, store it as an array or dictionary and then pass to CollectionView generation
    private func filteringTrackers(curDayOfWeek: Int) {
//        print("in filteringTrackers - 1")
//        trackerCategoryStore.countEntities()
        var trackersFilteredByWeekdaysArray = [Tracker]()
        categories = []
//        trackerCategoryStore.retrieveAllTrackerCategoryTitles()
//        let trackersFilteredFirst: [Tracker]? = trackerStore.filterTrackersByWeekday(dayOfWeek: curDayOfWeek)
        trackersFilteredByWeekdaysDictionary = trackerStore.filterTrackersByWeekday(dayOfWeek: curDayOfWeek)
        
        // MARK: TODO: NB! somehow adds empty TrackerCategory to TrackerCategoryCoreData - commented for now
//        var categoryAndItsTrackersFilteredFirst: [TrackerCategory]? = trackerCategoryStore.findCategoryWithSuitableTrackers(dayOfWeek: curDayOfWeek)
//        print("categoryAndItsTrackersFilteredFirst", categoryAndItsTrackersFilteredFirst?.count)
        guard let trackersFilteredByWeekdaysDictionary else { return }
        for item in trackersFilteredByWeekdaysDictionary {
            let trackerCategoryTitle = item.key
//            print("trackerCategoryTitle", trackerCategoryTitle)
            trackersFilteredByWeekdaysArray = item.value.filter { tracker in
                guard let id = tracker.id else { return false }
                let selectedDateString = getDateFromDatePicker(date: selectedDate)
                let isTrackerWithIdinTrackerRecords = trackerRecordStore.countEntities(id: id)
                let isTrackerWithIdAndDateinTrackerRecords = trackerRecordStore.checkDateForCompletedTrackersInCoreData(trackerRecord: TrackerRecord(id: id, dateExecuted: selectedDateString))
                if !tracker.schedule.isEmpty { return true }
                print("!tracker.schedule.isEmpty", !tracker.schedule.isEmpty, tracker.schedule)
                if isTrackerWithIdAndDateinTrackerRecords { return true }
                print("isTrackerWithIdAndDateinTrackerRecords", isTrackerWithIdAndDateinTrackerRecords)
                if tracker.schedule.isEmpty && isTrackerWithIdinTrackerRecords == 0 { return true }
                print("tracker.schedule.isEmpty && isTrackerWithIdinTrackerRecords == 0", tracker.schedule.isEmpty && isTrackerWithIdinTrackerRecords == 0)
                return false
            }
            print("trackersFilteredByWeekdaysArray", trackersFilteredByWeekdaysArray)
            let trackerCategoryAfterSelection = TrackerCategory(title: trackerCategoryTitle, trackerArray: trackersFilteredByWeekdaysArray)
            print("trackerCategoryAfterSelection", trackerCategoryAfterSelection)
            if !trackerCategoryAfterSelection.trackerArray.isEmpty {
                categories.append(trackerCategoryAfterSelection)
                categories.sort(by: { $0.title! < $1.title! })
            }
//            trackersFilteredByWeekdaysDictionary[trackerCategoryTitle] = trackersFilteredByWeekdaysArray
        }
//        trackersFilteredByWeekdays = trackersFilteredFirst.filter { tracker in
//            guard let id = tracker.id else { return false }
//            let selectedDateString = getDateFromDatePicker(date: selectedDate)
//            let isTrackerWithIdinTrackerRecords = trackerRecordStore.countEntities(id: id)
//            let isTrackerWithIdAndDateinTrackerRecords = trackerRecordStore.checkDateForCompletedTrackersInCoreData(trackerRecord: TrackerRecord(id: id, dateExecuted: selectedDateString))
//            if !tracker.schedule.isEmpty { return true }
//            if isTrackerWithIdAndDateinTrackerRecords { return true }
//            if tracker.schedule.isEmpty && isTrackerWithIdinTrackerRecords == 0 { return true }
//            return false
//        }
//        print(trackersFilteredByWeekdays)
//        print("Tracker category dictionary", trackersFilteredByWeekdaysDictionary)
//        categories.sort
//        trackersFilteredByWeekdays.sorted { $0. .category.title < $1.category.title }
        
//        print("in filteringTrackers - 2")
//        trackerCategoryStore.countEntities()
//        trackerCategoryStore.retrieveAllTrackerCategoryTitles()
    }
    
    private func togglingCompletedTrackers(trackerId: UUID, date: Date) {
        let trackerDate = getDateFromDatePicker(date: date)
        let trackerToHandle = TrackerRecord(id: trackerId, dateExecuted: trackerDate)
        if !trackerRecordStore.checkDateForCompletedTrackersInCoreData(trackerRecord: trackerToHandle) {
            try? trackerRecordStore.addTrackerRecordToCoreData(trackerToHandle)
        } else {
            trackerRecordStore.deleteTrackerRecord(by: trackerId, date: trackerDate)
        }
    }
    
    private func checkingCompletedTrackers(trackerId: UUID) -> Bool {
        let trackerDate = getDateFromDatePicker(date: selectedDate)
        let trackerToCheck = TrackerRecord(id: trackerId, dateExecuted: trackerDate)
        return trackerRecordStore.checkDateForCompletedTrackersInCoreData(trackerRecord: trackerToCheck)
    }
    
    private func getDateFromDatePicker(date: Date) -> String {
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: date)
    }
    
    private func arrayToUse() {
        //        trackersToDisplay = trackersFilteredByWeekdays
        //        if trackersToDisplay.count == 0 {
        //            imageView.isHidden = false
        //            initLogo.isHidden = false
        //        } else {
        //            imageView.isHidden = true
        //            initLogo.isHidden = true
        //        }
        if categories.isEmpty {
            imageView.isHidden = false
            initLogo.isHidden = false
        } else {
            imageView.isHidden = true
            initLogo.isHidden = true
        }
    }
    
    // MARK: @objc functions
    @objc func dateChanged(sender: UIDatePicker) {
        selectedDate = sender.date
        let curDayOfWeek = sender.calendar.component(.weekday, from: selectedDate) - 1
        filteringTrackers(curDayOfWeek: curDayOfWeek)
        arrayToUse()
//        if trackersToDisplay.isEmpty {
        if categories.isEmpty {
            imageView.isHidden = false
            initLogo.isHidden = false
        } else {
            imageView.isHidden = true
            initLogo.isHidden = true
        }
        collectionView.reloadData()
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
        //        return trackersToDisplay.count
        return categories[section].trackerArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerCellViewController
        guard let cell,
              let element = categories[indexPath.section].trackerArray[indexPath.row],
              let id = element.id,
              let color = element.color,
              let emoji = element.emojiPic,
              let text = element.name
                //              let id = trackersToDisplay[indexPath.item].id,
                //              let color = trackersToDisplay[indexPath.item].color,
                //              let emoji = trackersToDisplay[indexPath.item].emojiPic,
                //              let text = trackersToDisplay[indexPath.item].name else { return UICollectionViewCell() }
        else {
            debugPrint("error for cell")
            return UICollectionViewCell()
        }
//        print("indexPath.section, indexPath.row", indexPath.section, indexPath.row)
//        print("element", element, element.name, element.id)
        cell.layer.cornerRadius = 10
        trackerRecordStore.setTrackerRecordParams(trackerId: id, currentCell: cell)
        changeCellButton(cell: cell, trackerId: id)
        trackerCompletedDaysCount(cell: cell, trackerId: id)
        cell.setColorsInCell(color: color)
        cell.setEmoji(emoji: emoji)
        cell.setLabelText(text: text)
        cell.tintColor = .clear
        cell.tappedRecordButton = { [weak self] in
            guard let self else { return }
            trackerRecordStore.setTrackerRecordParams(trackerId: id, currentCell: cell)
            self.togglingCompletedTrackers(trackerId: id, date: selectedDate)
            // Вызовы функций переключены на уведомления в CoreData; удалить впоследствии
            //            changeCellButton(cell: cell, trackerId: id)
            //            trackerCompletedDaysCount(cell: cell, trackerId: id)
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
//        print("For header", indexPath.section, categories[indexPath.section].title)
        let headerText = categories[indexPath.section].title
//        print("For header text", headerText)
        supplementaryView.headerLabel.text = headerText
//        supplementaryView.headerLabel.textColor = .ypBlack
        supplementaryView.systemLayoutSizeFitting(CGSize(width: supplementaryView.frame.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
//        if trackersToDisplay.isEmpty == true {
        if categories.isEmpty == true {
            supplementaryView.isHidden = true
        } else {
            supplementaryView.isHidden = false
        }
        return supplementaryView
    }
    
    private func trackerCompletedDaysCount(cell: TrackerCellViewController, trackerId: UUID) {
        let counter = trackerRecordStore.countEntities(id: trackerId)
        //        for element in completedTrackers {
        //            if element.id == trackerId {
        //                counter += 1
        //            }
        //        }
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

