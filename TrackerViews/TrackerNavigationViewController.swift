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

enum MockTrackers {
    case mockTracker1
    case mockTracker2
    
    var usedTracker: Tracker {
        switch self {
        case .mockTracker1:
            return Tracker(id: UUID(), name: "test tracker 1", emojiPic: "🍇", color: .green , schedule: [.Mon, .Sun])
        case .mockTracker2:
            return Tracker(id: UUID(), name: "test tracker 2", emojiPic: "🍈", color: .red, schedule: [.Mon, .Thu, .Sun])
        }
    }
}

enum ViewControllerState {
    case creating
    case editing(tracker: Tracker)
}

enum ViewControllerForCategoryState {
    case creating
    case editing(existingCategoryName: String)
}

final class TrackerNavigationViewController: UIViewController, TrackerNavigationViewProtocol {
    
    private let storage: UserDefaults = .standard
    private var categories = [TrackerCategory]()
    private var trackerCategory: TrackerCategory?
    private var completedTrackers = [TrackerRecord]()
    private var trackersFilteredByWeekdaysDictionary: [String: [Tracker]]? = [:]
    private let trackerColorSet = [UIColor.ypBlack, UIColor.ypDarkRed, UIColor.ypDarkBlue, UIColor.ypDarkGreen]
    private let params = GeometricParams(leftInset: 16, rightInset: 16, cellSpacing: 10)
    
    private var dateField = UITextField()
    private let localeID = Locale.preferredLanguages.first
    private var currentDate = Date()
    private var selectedDate = Date()
    private let createTracker = TrackerCreateVC()
    private let emojiArray = EmojiArray
    private let colorsArray = Colors
    private let pinnedCategoryName = pinnedHeaderText
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private var searchBarText = ""
    private var currentTrackerItem: Tracker?
    private var setFilter: FilterNameEnum?
    private var completedTrackersFlag: Bool? = nil
    private let analyticsService = AnalyticsService()
    
    // MARK: mock trackers and mock tracker creation function - to be deleted
    
    //    func tempMockTrackerSetup() {
    ////        var colorNum = Int.random(in: 0..<3) // Number to take UIColor from arrays
    //        var emojiNum = Int.random(in: 0..<emojiArray.count)
    //        let mockUUID = UUID()
    ////        mockTracker1 = Tracker(id: mockUUID, name: "test tracker 1", emojiPic: emojiArray[emojiNum], color: trackerColorSet[colorNum] , schedule: [.Mon, .Sun])
    //        mockTracker1 = Tracker(id: mockUUID, name: "test tracker 1", emojiPic: emojiArray[emojiNum], color: trackerColorSet[1] , schedule: [.Mon, .Sun])
    ////        colorNum = Int.random(in: 0..<3) // Number to take UIColor from arrays
    ////        emojiNum = Int.random(in: 0..<emojiArray.count)
    ////        mockTracker2 = Tracker(id: 2, name: "test tracker 2", emojiPic: emojiArray[emojiNum], color: trackerColorSet[colorNum], schedule: [.Thu, .Sun])
    //        allTrackers.append(mockTracker1)
    ////        allTrackers.append(mockTracker2)
    ////        categories[0].trackerArray.append(mockTracker1)
    ////        categories[0].trackerArray.append(mockTracker2)
    //////        print(categories) //, categories[0])
    //    }
    // MARK: mock trackers and mock tracker creation function END
    
    private lazy var searchBar: UISearchController = {
        var searchField = UISearchController()
        searchField.searchBar.placeholder = searchBarPlaceholder
        searchField.searchBar.backgroundColor = TrackerColors.viewBackgroundColor
        searchField.searchResultsUpdater = self
        searchField.obscuresBackgroundDuringPresentation = false
        searchField.hidesNavigationBarDuringPresentation = false
        searchField.searchBar.tintColor = TrackerColors.backgroundButtonColor
        searchField.searchBar.delegate = self
        searchField.delegate = self
        return searchField
    }()
    
    private lazy var trackerFiltersButton: UIButton = {
        let trackerFiltersButton = UIButton()
        trackerFiltersButton.layer.cornerRadius = 16
        trackerFiltersButton.backgroundColor = .ypBlue
        trackerFiltersButton.setTitleColor(.ypWhite, for: .normal)
        trackerFiltersButton.setTitle(filterButtonText, for: .normal)
        trackerFiltersButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        trackerFiltersButton.addTarget(self, action: #selector(tappedTrackerFilterButton), for: .touchUpInside)
        return trackerFiltersButton
    }()
    
    private lazy var trackerCollectionView: UICollectionView = {
        let trackerCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        trackerCollectionView.backgroundColor = .clear
        trackerCollectionView.allowsMultipleSelection = false
        trackerCollectionView.isScrollEnabled = true
        trackerCollectionView.dataSource = self
        trackerCollectionView.delegate = self
        trackerCollectionView.contentInset.bottom = 50
        trackerCollectionView.register(TrackerCellViewController.self, forCellWithReuseIdentifier: "trackerCell")
        return trackerCollectionView
    }()
    
    private lazy var imageView: UIImageView = {
        let image = UIImage.flyingStar
        let imageView = UIImageView(image: image)
        imageView.backgroundColor = TrackerColors.viewBackgroundColor
        return imageView
    }()
    
    private lazy var initLogo: UILabel = {
        let initLogo = UILabel()
        initLogo.backgroundColor = TrackerColors.viewBackgroundColor
        initLogo.text = initLogoText
        initLogo.font = .systemFont(ofSize: 12, weight: .medium)
        initLogo.textColor = TrackerColors.backgroundButtonColor
        initLogo.sizeToFit()
        return initLogo
    }()
    
    private lazy var emptySearchImage: UIImageView = {
        let image = UIImage.emptySearch
        let emptySearchImage = UIImageView(image: image)
        emptySearchImage.backgroundColor = TrackerColors.viewBackgroundColor
        emptySearchImage.isHidden = true
        return emptySearchImage
    }()
    
    private lazy var emptySearchLabel: UILabel = {
        let emptySearchLabel = UILabel()
        emptySearchLabel.backgroundColor = TrackerColors.viewBackgroundColor
        emptySearchLabel.text = emptySearchText
        emptySearchLabel.font = .systemFont(ofSize: 12, weight: .medium)
        emptySearchLabel.textColor = TrackerColors.backgroundButtonColor
        emptySearchLabel.isHidden = true
        emptySearchLabel.sizeToFit()
        return emptySearchLabel
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
        dateFormatter.locale = Locale.current
        return dateFormatter
    }()
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        analyticsService.report(event: "open", params: ["screen" : "Main"])
        // MARK: temp function calls and variables
        //        deleteAllTrackers()
        //        countAllTrackersData()
        //        showAllTrackersData()
        //        retrieveAllTrackers()
        //        tempMockTrackerSetup() // calling mockTracker setup function
        //        trackerStore.deleteEntities()
        //        var mockTracker2 = trackerStore.retrieveAllTrackers()
        //        allTrackers.append(mockTracker2)
        //        var strWeekDays = trackerStore.scheduleToString(schedule: [.Mon, .Wed])
        //        let lineStr = trackerStore.stringToSchedule(scheduleString: strWeekDays)
        //        print("in viewDidLoad", strWeekDays, lineStr)
        // MARK: end of temp function calls and variables
        
//        trackerCategoriesSetup()
        createTracker.delegateTracker = self
        trackerStore.delegateTrackerForNotifications = self
        naviBarSetup()
        setupNaviVC()
        setupSetFilterState() 
        checkIfPinnedExists()
        showingTrackersForCurrentDate()
    }
    
    // MARK: Public functions
    
    func addingTrackerOnScreen() {
        switch setFilter {
        case .allTrackers:
            completedTrackersFlag = nil
            showingTrackersForSelectedDate()
        case .todayTrackers:
            completedTrackersFlag = nil
            showingTrackersForCurrentDate()
            datePicker.date = currentDate
            selectedDate = currentDate
        case .completedTrackers:
            completedTrackersFlag = true
            showingTrackersForSelectedDate()
        case .uncompletedTrackers:
            completedTrackersFlag = false
            showingTrackersForSelectedDate()
        default:
            completedTrackersFlag = nil
            showingTrackersForSelectedDate()
        }
        imagesToShowOnEmptyScreen()
        trackerCollectionView.reloadData()
    }
    
    // MARK: Private functions
    
    private func setupSetFilterState() {
        let storedFilter = storage.string(forKey: "storedFilter")
        if storedFilter != nil {
            setFilter = FilterNameEnum(rawValue: storedFilter!)
        }
        setFilterButtonTextColor()
    }
    
    private func checkIfPinnedExists() {
        if !trackerCategoryStore.isCategoryAlreadyExist(categoryName: "Pinned") {
            try? trackerCategoryStore.addTrackerCategoryTitleToCoreData("Pinned")
        }
    }
    
    // TODO: temp function to be deleted
    private func deleteAllTrackers() {
        trackerStore.deleteAllTrackerCoreDataEntities()
        trackerRecordStore.deleteAllTrackerRecordCoreDataEntities()
        trackerCategoryStore.deleteAllTrackerCategoryCoreDataEntities()
    }
    
    // TODO: temp function to be deleted
    private func trackerCategoriesSetup() {
//        trackerStore.retrieveAllTrackers()
        // lines to be deleted
        //        mockCategoryAdding()
        //        trackerStore.countAllEntities()
        //        trackerCategoryStore.countEntities()
        //        trackerCategoryStore.retrieveAllTrackerCategories()
    }
    
    // TODO: temp function to be deleted
//    private func countAllTrackersData() {
//        trackerStore.countAllEntities()
//        trackerCategoryStore.countEntities()
//        trackerCategoryStore.countEntities()
//    }
    
    // TODO: temp function to be deleted
//    private func showAllTrackersData() {
//        print(trackerStore.retrieveAllTrackers())
//        trackerCategoryStore.retrieveCategoryTitles()
//        trackerRecordStore.retrieveAllTrackerRecordCoreDataInfo()
//    }
    
    // TODO: to be deleted
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
        if categories.isEmpty {
            imagesToShowOnEmptyScreen()
            collectionViewSetup()
        } else {
            imagesToShowOnEmptyScreen()
            collectionViewSetup()
        }
        trackerCollectionView.reloadData()
    }
    
    private func imagesToShowOnEmptyScreen() {
        if categories.isEmpty && searchBarText == "" && setFilter == nil {
            imageView.isHidden = false
            initLogo.isHidden = false
            emptySearchImage.isHidden = true
            emptySearchLabel.isHidden = true
            trackerFiltersButton.isHidden = true
        } else if !categories.isEmpty && searchBarText == "" || setFilter == nil {
            imageView.isHidden = true
            initLogo.isHidden = true
            emptySearchImage.isHidden = true
            emptySearchLabel.isHidden = true
            trackerFiltersButton.isHidden = false
        } else if categories.isEmpty && searchBarText != "" || setFilter == nil {
            imageView.isHidden = true
            initLogo.isHidden = true
            emptySearchImage.isHidden = false
            emptySearchLabel.isHidden = false
            trackerFiltersButton.isHidden = true
        } else if categories.isEmpty && searchBarText != "" || setFilter != nil {
            imageView.isHidden = true
            initLogo.isHidden = true
            emptySearchImage.isHidden = false
            emptySearchLabel.isHidden = false
            trackerFiltersButton.isHidden = false
        } else {
            trackerFiltersButton.isHidden = false
            imageView.isHidden = true
            initLogo.isHidden = true
            emptySearchImage.isHidden = true
            emptySearchLabel.isHidden = true
        }
    }
    
    private func emptyTrackerSetup() {
        view.backgroundColor = TrackerColors.viewBackgroundColor
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
        view.backgroundColor = TrackerColors.viewBackgroundColor
        let objectsToShow = [emptySearchImage, emptySearchLabel, trackerCollectionView, trackerFiltersButton]
        objectsToShow.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        NSLayoutConstraint.activate([
            trackerCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackerCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackerCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            emptySearchImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptySearchImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptySearchImage.heightAnchor.constraint(equalToConstant: 80),
            emptySearchImage.widthAnchor.constraint(equalToConstant: 80),
            emptySearchLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptySearchLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            trackerFiltersButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:130),
            trackerFiltersButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -130),
            trackerFiltersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            trackerFiltersButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        trackerCollectionView.register(SupplementaryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
    }
    
    private func naviBarSetup() {
        addHabitButton.tintColor = TrackerColors.backgroundButtonColor
        self.navigationItem.leftBarButtonItem = addHabitButton
        navigationItem.title = naviBarTitle
        navigationController?.navigationBar.backgroundColor = TrackerColors.viewBackgroundColor
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchBar
        let myDateField = UIBarButtonItem(customView: datePicker)
        dateField.backgroundColor = .ypLightGray
        dateField.tintColor = .ypBlack
        dateField.inputView = datePicker
        
        // MARK: TODO: Locale set to RU. Can be switched to current settings-dependent
        guard let localeID else { return }
        datePicker.locale = Locale(identifier: localeID)
        //        datePicker.locale = Locale(identifier: "ru-RU")
        navigationItem.rightBarButtonItem = myDateField
        tabBarController?.tabBar.backgroundColor = TrackerColors.viewBackgroundColor
    }
    
    private func showingTrackersForCurrentDate() {
        let curDayOfWeek = Calendar.current.component(.weekday, from: currentDate)
        filteringTrackers(curDayOfWeek: curDayOfWeek - 1, usedDate: currentDate)
    }
    
    private func showingTrackersForSelectedDate() {
        let curDayOfWeek = Calendar.current.component(.weekday, from: selectedDate)
        filteringTrackers(curDayOfWeek: curDayOfWeek - 1, usedDate: selectedDate)
    }
    
    // MARK: filteringTrackers
    //The function filters trackers by weekdays from the CategoryStore, stores them as an array or dictionary and then passes for CollectionView generation
    private func filteringTrackers(curDayOfWeek: Int, usedDate: Date) {
        var trackersFilteredByWeekdaysArray = [Tracker]()
        var finalArray = [Tracker]()
        let usedDateString = getDateFromDatePicker(date: usedDate)
        categories = []
        trackersFilteredByWeekdaysDictionary = trackerStore.filterTrackersByWeekday(dayOfWeek: curDayOfWeek)

        guard let trackersFilteredByWeekdaysDictionary else { return }
        for item in trackersFilteredByWeekdaysDictionary {
            let trackerCategoryTitle = item.key
            trackersFilteredByWeekdaysArray = item.value.filter { tracker in
                guard let id = tracker.id, let name = tracker.name else { return false }
                let trackerNameAfterSelection = name.lowercased().contains(searchBarText.lowercased())
                if searchBarText != "" && !trackerNameAfterSelection { return false }
                let isTrackerWithIdinTrackerRecords = trackerRecordStore.countEntities(id: id)
                let isTrackerWithIdAndDateinTrackerRecords = trackerRecordStore.checkDateForCompletedTrackersInCoreData(trackerRecord: TrackerRecord(id: id, dateExecuted: usedDateString))
                if !tracker.schedule.isEmpty { return true }
                if isTrackerWithIdAndDateinTrackerRecords { return true }
                if tracker.schedule.isEmpty && isTrackerWithIdinTrackerRecords == 0 { return true }
                return false
            }
            
            switch completedTrackersFlag {
            case true:
                finalArray = trackersFilteredByWeekdaysArray.filter { tracker in
                    guard let id = tracker.id else { return false }
                    return trackerRecordStore.checkDateForCompletedTrackersInCoreData(trackerRecord: TrackerRecord(id: id, dateExecuted: usedDateString))
                }
            case false:
                finalArray = trackersFilteredByWeekdaysArray.filter { tracker in
                    guard let id = tracker.id else { return false }
                    return !trackerRecordStore.checkDateForCompletedTrackersInCoreData(trackerRecord: TrackerRecord(id: id, dateExecuted: usedDateString))
                }
            default:
                finalArray = trackersFilteredByWeekdaysArray
            }
            
            let trackerCategoryAfterSelection = TrackerCategory(title: trackerCategoryTitle, trackerArray: finalArray)
            if !trackerCategoryAfterSelection.trackerArray.isEmpty {
                categories.append(trackerCategoryAfterSelection)
                categories.sort(by: { $0.title! < $1.title! })
                if let pinnedCategory = categories.firstIndex(where: {
                    $0.title == "Pinned"
                }) {
                    let transferredTrackerCategory = categories.remove(at: pinnedCategory)
                    categories.insert(transferredTrackerCategory, at: 0)
                }
            }
        }
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
    
    private func setFilterButtonTextColor() {
        if setFilter == nil || setFilter == .allTrackers {
            trackerFiltersButton.setTitleColor(.ypWhite, for: .normal)
        } else {
            trackerFiltersButton.setTitleColor(.ypRed, for: .normal)
        }
    }
    
    // MARK: @objc functions
    @objc func dateChanged(sender: UIDatePicker) {
        analyticsService.report(event: "click", params: ["screen" : "Main", "item" : "edit"])
        selectedDate = sender.date
        addingTrackerOnScreen()
    }
    
    @objc func leftAddHabit() {
        analyticsService.sendEvent(event: "open", screen: "Main")
        let navigationController = UINavigationController(rootViewController: createTracker)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true)
    }
    
    @objc func tappedTrackerFilterButton() {
        analyticsService.sendEvent(event: "click", screen: "Main", item: "filter")
        let filtersVC = FiltersVC()
        let navigationController = UINavigationController(rootViewController: filtersVC)
        filtersVC.selectedFilter = setFilter
        filtersVC.modalPresentationStyle = .pageSheet
        filtersVC.isModalInPresentation = true
        filtersVC.tappedFilter = { [weak self] setFilter in
            guard let self else { return }
            self.setFilter = setFilter
            storage.set(setFilter.rawValue, forKey: "storedFilter")
            filtersVC.dismiss(animated: true)
            setFilterButtonTextColor()
            addingTrackerOnScreen()
        }
        present(navigationController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension TrackerNavigationViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imagesToShowOnEmptyScreen()
        return categories[section].trackerArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trackerCell", for: indexPath) as? TrackerCellViewController
        guard let cell,
              let element = categories[indexPath.section].trackerArray[indexPath.row],
              let id = element.id,
              let color = element.color,
              let emoji = element.emojiPic,
              let text = element.name
        else {
            debugPrint("error for cell")
            return TrackerCellViewController()
        }
        //        cell.isUserInteractionEnabled = true
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
        }
        cell.tappedCellButton = { [weak self] in
            guard let self else { return UUID() }
            self.analyticsService.sendEvent(event: "click", screen: "Main", item: "track")
            currentTrackerItem = element
            return id
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
        let headerText = categories[indexPath.section].title
        supplementaryView.headerLabel.text = (headerText == "Pinned" ? pinnedHeaderText : headerText)
        supplementaryView.systemLayoutSizeFitting(CGSize(width: supplementaryView.frame.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
        if categories.isEmpty == true {
            supplementaryView.isHidden = true
        } else {
            supplementaryView.isHidden = false
        }
        return supplementaryView
    }
    
    private func trackerCompletedDaysCount(cell: TrackerCellViewController, trackerId: UUID) {
        let counter = trackerRecordStore.countEntities(id: trackerId)
        cell.setDayLabelText(days: counter)
    }
    
    private func changeCellButton(cell: TrackerCellViewController, trackerId: UUID) {
        checkingCompletedTrackers(trackerId: trackerId) ? cell.setButtonSign(isPlusSignOnFlag: true) : cell.setButtonSign(isPlusSignOnFlag: false)
    }
    
    // MARK: pinTracker()    private func pinTracker(cell: TrackerCellViewController, trackerId: UUID) {
    private func pinTracker(indexPath: IndexPath) {
        analyticsService.sendEvent(event: "click", screen: "Main", item: "pin")
        guard let trackerID = currentTrackerItem?.id else {
            print("error with trackerID \(currentTrackerItem?.id)")
            return
        }
        trackerStore.switchTrackerCategories(by: trackerID)
    }
    
    //    private func editTracker(cell: TrackerCellViewController, trackerId: UUID) {
    private func editTracker(indexPath: IndexPath) {
        analyticsService.sendEvent(event: "click", screen: "Main", item: "edit")
        guard let trackerID = currentTrackerItem?.id else {
            print("error with trackerID \(currentTrackerItem?.id), editTracker, TrackerNavigationViewController")
            return
        }
        let trackerToEdit = trackerStore.retrieveTracker(by: trackerID)
        guard let trackerToEdit else { return }
        if trackerToEdit.schedule != [] {
            let editHabitVC = NewHabitVC()
            let navigationController = UINavigationController(rootViewController: editHabitVC)
            navigationController.modalPresentationStyle = .formSheet
            editHabitVC.isModalInPresentation = true
            editHabitVC.habitViewState = .editing(tracker: trackerToEdit)
            present(navigationController, animated: true)
        } else {
            let editEventVC = NewEventVC()
            let navigationController = UINavigationController(rootViewController: editEventVC)
            navigationController.modalPresentationStyle = .formSheet
            editEventVC.isModalInPresentation = true
            editEventVC.eventViewState = .editing(tracker: trackerToEdit)
            present(navigationController, animated: true)
        }
    }
    
    private func deleteTracker(indexPath: IndexPath) {
        analyticsService.sendEvent(event: "click", screen: "Main", item: "delete")
        guard let trackerID = currentTrackerItem?.id else { return }
        trackerRecordStore.deleteTrackerRecordByID(by: trackerID)
        trackerStore.deleteTracker(by: trackerID)
        trackerStore.countAllEntities()
        trackerCategoryStore.countEntities()
        trackerCollectionView.reloadData()
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

extension TrackerNavigationViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //        print("cell.element.name: \(cell?.tappedCellButton element.name)")
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPaths.count > 0 else { return nil }
        let indexPath = indexPaths[0]
        let cell = collectionView.cellForItem(at: indexPath) as? TrackerCellViewController
        guard let cell, let trackerAction = cell.tappedCellButton else { return nil }
        let currentTrackerID = trackerAction()
        let pinStateValue = trackerStore.isPinnedState(by: currentTrackerID)
        var pinAction: String {
            if pinStateValue == "Pinned" {
                return pinActionText
            } else {
                return unPinActionText
            }
        }
        
        return UIContextMenuConfiguration(actionProvider: { actions in
            return UIMenu(children: [
                UIAction(title: pinAction) { [weak self] _ in
                    guard let self else { return }
                    self.pinTracker(indexPath: indexPath)
                },
                UIAction(title: editActionText) { [weak self] _ in
                    guard let self else { return }
                    self.editTracker(indexPath: indexPath)
                },
                UIAction(title: deleteActionText, attributes: .destructive) { [weak self] _ in
                    guard let self else { return }
                    self.deleteTracker(indexPath: indexPath)
                }
            ])
        })
    }
}

//MARK: - UISearchController

extension TrackerNavigationViewController: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text == "" {
            searchBarText = ""
            showingTrackersForSelectedDate()
            trackerCollectionView.reloadData()
            imagesToShowOnEmptyScreen()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBarText = searchBar.text ?? ""
        showingTrackersForSelectedDate()
        trackerCollectionView.reloadData()
        imagesToShowOnEmptyScreen()
    }
}

