//
//  NewHabitVC.swift
//  Tracker
//
//  Created by Valery Zvonarev on 12.11.2024.
//

import UIKit

protocol TrackerNavigationViewProtocol: AnyObject {
    func addingTrackerOnScreen()
}

protocol TrackerCreateVCProtocol: AnyObject {
    func getDelegateTracker() -> TrackerNavigationViewProtocol
}

final class NewHabitVC: UIViewController {
    
    private let buttonNameArray = [(trackerCategory, trackerCategoryName), (trackerSchedule, trackersDaysOfWeek)]
    weak var delegateTrackerInNewHabitVC: TrackerCreateVCProtocol?
    private var categoryCell = UITableViewCell()
    private var scheduleCell = UITableViewCell()
    private var selectedEmojiCell = CellCollectionViewController()
    private var selectedColorCell = CellCollectionViewController()
    private let params = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    private let layout = UICollectionViewFlowLayout()
    private var habitViewTitle = ""
    private var createOrSaveButtonText = ""
    
    //CoreData stores
    private let trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    //tracker params
    private var editedTracker: Tracker?
    private var selectedCategory: TrackerCategory?
    private var selectedCategoryName: String?
    //    private var textInTextfield = ""
    private var selectedEmoji = "🙂"
    private var selectedColor: UIColor = .ypDarkRed
    private var daysString: String?
    private var daysToSend = [ScheduledDays]()
    private var emojiSelected = false
    private var colorSelected = false
    
    private let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🫢", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    
    private let colors = Colors
    private var selectedIndexPaths: [Int: IndexPath] = [:]
    private let analyticsService = AnalyticsService()
    
    var habitViewState: viewControllerState = .creating {
        didSet {
            updateUIForState()
        }
    }
    
    private lazy var trackerNameTextfield: UITextField = {
        var trackerNameTextfield = UITextField()
        trackerNameTextfield.backgroundColor = .ypBackground
        trackerNameTextfield.layer.cornerRadius = 16
        trackerNameTextfield.clearButtonMode = .whileEditing
        trackerNameTextfield.placeholder = trackerNamePlaceholder
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 20))
        trackerNameTextfield.leftView = paddingView
        trackerNameTextfield.leftViewMode = .always
        trackerNameTextfield.delegate = self
        trackerNameTextfield.addTarget(self, action: #selector(editingTrackerName(_ :)), for: .editingChanged)
        return trackerNameTextfield
    }()
    
    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.backgroundColor = TrackerColors.viewBackgroundColor
        cancelButton.layer.cornerRadius = 16
        cancelButton.setTitleColor(.ypRed, for: .normal)
        cancelButton.setTitle(cancelButtonText, for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        cancelButton.layer.borderColor = UIColor.ypRed.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.addTarget(self, action: #selector(cancelHabitCreation), for: .touchUpInside)
        return cancelButton
    }()
    
    private lazy var createOrSaveButton: UIButton = {
        let createOrSaveButton = UIButton()
        createOrSaveButton.layer.cornerRadius = 16
        createOrSaveButton.backgroundColor = .ypGray
        createOrSaveButton.isEnabled = false
        createOrSaveButton.setTitleColor(TrackerColors.buttonTintColor, for: .normal)
        createOrSaveButton.setTitleColor(.ypWhite, for: .disabled)
        //        createOrSaveButton.setTitle(createOrSaveButtonText, for: .normal)
        createOrSaveButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        createOrSaveButton.addTarget(self, action: #selector(createHabit), for: .touchUpInside)
        return createOrSaveButton
    }()
    
    private lazy var buttonTableView: UITableView = {
        let buttonTableView = UITableView()
        buttonTableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableCell")
        buttonTableView.backgroundColor = .ypBackground
        buttonTableView.isScrollEnabled = false
        buttonTableView.delegate = self
        buttonTableView.dataSource = self
        buttonTableView.separatorStyle = .singleLine
        buttonTableView.separatorInset.left = 16
        buttonTableView.separatorInset.right = 16
        buttonTableView.layer.cornerRadius = 16
        buttonTableView.layer.masksToBounds = true
        buttonTableView.clipsToBounds = true
        return buttonTableView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.alwaysBounceVertical = true
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let emojiAndColorsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        emojiAndColorsCollectionView.backgroundColor = TrackerColors.viewBackgroundColor
        emojiAndColorsCollectionView.isScrollEnabled = false
        emojiAndColorsCollectionView.allowsMultipleSelection = true
        emojiAndColorsCollectionView.dataSource = self
        emojiAndColorsCollectionView.delegate = self
        emojiAndColorsCollectionView.register(CellCollectionViewController.self, forCellWithReuseIdentifier: "cellEmojiAndColors")
        emojiAndColorsCollectionView.register(SupplementaryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        emojiAndColorsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
        return emojiAndColorsCollectionView
    }()
    
    private lazy var containingView = {
        let containingView = UIView()
        containingView.backgroundColor = .clear
        return containingView
    }()
    
    private lazy var stackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createOrSaveButton])
        stackView.backgroundColor = .clear
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = habitViewTitle
        viewSetup()
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    // MARK: Public functions
    func defaultFields() {
        trackerNameTextfield.text = ""
        createOrSaveButton.isEnabled = false
        categoryCell.detailTextLabel?.text = buttonNameArray[0].1
        scheduleCell.detailTextLabel?.text = buttonNameArray[1].1
    }
    
    // MARK: Private functions
    private func updateUIForState() {
        switch habitViewState {
        case .editing(let tracker):
            habitViewTitle = editTrackerTitle
            createOrSaveButton.setTitle(saveButtonText, for: .normal)
            setEditedTrackersData(tracker: tracker)
            emojiSelected = true
            colorSelected = true
        case .creating:
            defaultFields()
            habitViewTitle = newTrackerTitle
            createOrSaveButton.setTitle(createButtonText, for: .normal)
            emojiSelected = false
            colorSelected = false
        }
    }
    
    func setEditedTrackersData(tracker: Tracker) {
        guard let trackerID = tracker.id, let trackerName = tracker.name, let emojiPic = tracker.emojiPic, let color = tracker.color else { return }
        trackerNameTextfield.text = trackerName
        selectedCategoryName = trackerStore.retrieveTrackerCategoryByID(by: trackerID)
        let scheduleToIntArray: [Int] = tracker.schedule.map { $0.rawValue }
        daysString = intsToDaysOfWeek(dayArray: scheduleToIntArray)
    }
    
    private func viewSetup() {
        view.backgroundColor = TrackerColors.viewBackgroundColor
        [scrollView, stackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        containingView.translatesAutoresizingMaskIntoConstraints = false
        TrackerColors.setPlaceholderTextColor(textField: trackerNameTextfield)
        
        scrollView.addSubview(containingView)
        let containedArray = [trackerNameTextfield, buttonTableView, emojiCollectionView]
        containedArray.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containingView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -16),
            
            containingView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containingView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containingView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containingView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containingView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            trackerNameTextfield.leadingAnchor.constraint(equalTo: containingView.leadingAnchor, constant: 16),
            trackerNameTextfield.trailingAnchor.constraint(equalTo: containingView.trailingAnchor, constant: -16),
            trackerNameTextfield.topAnchor.constraint(equalTo: containingView.topAnchor, constant: 24),
            trackerNameTextfield.heightAnchor.constraint(equalToConstant: 75),
            
            buttonTableView.leadingAnchor.constraint(equalTo: containingView.leadingAnchor, constant: 16),
            buttonTableView.trailingAnchor.constraint(equalTo: containingView.trailingAnchor, constant: -16),
            buttonTableView.topAnchor.constraint(equalTo: trackerNameTextfield.bottomAnchor, constant: 24),
            buttonTableView.heightAnchor.constraint(equalToConstant: 149),
            
            emojiCollectionView.leadingAnchor.constraint(equalTo: containingView.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: containingView.trailingAnchor, constant: -16),
            emojiCollectionView.topAnchor.constraint(equalTo: buttonTableView.bottomAnchor, constant: 32),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 600),
            emojiCollectionView.bottomAnchor.constraint(equalTo: containingView.bottomAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
    }
    
    private func canEnableCreateButton() {
        guard let trackerName = trackerNameTextfield.text else { return }
        if (trackerName == "" || trackerName.count > 38 || selectedCategoryName == nil || daysString == nil || !emojiSelected || !colorSelected) {
            createOrSaveButton.isEnabled = false
            createOrSaveButton.backgroundColor = .ypGray
        } else {
            createOrSaveButton.isEnabled = true
            createOrSaveButton.backgroundColor = TrackerColors.backgroundButtonColor
            categoryCell.detailTextLabel?.text = selectedCategoryName
        }
        buttonTableView.reloadData()
    }
    
    private func intsToDaysOfWeek(dayArray: [Int]) -> String {
        if dayArray.count == 7 {
            daysToSend = dayArray.compactMap { ScheduledDays(rawValue: $0) }
            //            return "Каждый день"
            return returnedEveryDay
        }
        
        // TODO: adjust use of the Russian locale for days of week
        //        let russianLocale = Locale(identifier: "ru-RU")
        //        var russianCalendar = Calendar.current
        //        russianCalendar.locale = russianLocale
        //        let weekDaySymbols = russianLocale.calendar.shortWeekdaySymbols
        
        let currentLocale = Locale.current
        var currentCalendar = Calendar.current
        currentCalendar.locale = currentLocale
        let weekDaySymbolsShort = currentLocale.calendar.shortWeekdaySymbols
        
        daysToSend = dayArray.compactMap {
            return ScheduledDays(rawValue: $0)
        }
        var dayNames = dayArray.compactMap { index in
            index >= 0 && index < weekDaySymbolsShort.count ? weekDaySymbolsShort[index] : nil
        }
        if dayArray.first == 0 && currentLocale.identifier == "ru_RU" {
            let tempDay = dayNames.remove(at: 0)
            dayNames.insert(tempDay, at: (dayNames.count))
        }
        return dayNames.joined(separator: ", ")
    }
    
    private func resettingFields() {
        trackerNameTextfield.text = ""
        selectedEmojiCell.unsetImageViewColor(section: 0)
        selectedColorCell.unsetImageViewColor(section: 1)
        selectedCategoryName = nil
        daysString = nil
        emojiSelected = false
        colorSelected = false
    }
    
    // MARK: @objc functions
    @objc private func cancelHabitCreation() {
        analyticsService.sendEvent(event: "click", screen: "CreateHabit", item: "close")
        resettingFields()
        self.dismiss(animated: true)
    }
    
    @objc private func createHabit() {
        analyticsService.sendEvent(event: "click", screen: "CreateHabit", item: "add_track")
        guard let trackerText = trackerNameTextfield.text else { return }
        switch habitViewState {
        case .creating:
            let idNum = UUID()
            let addedTracker = Tracker(id: idNum, name: trackerText, emojiPic: selectedEmoji, color: selectedColor, schedule: daysToSend)
            let addedTrackerCoreData = try? trackerStore.addTrackerToCoreData(addedTracker)
            let trackerCategoryToAddTracker = trackerCategoryStore.findCategoryByName(categoryName: selectedCategoryName!)
            try? trackerCategoryStore.addTrackerToCategory(trackerCategoryToAddTracker!, trackerCoreData: addedTrackerCoreData!)
        case .editing(let tracker):
            let tempTracker = Tracker(id: tracker.id, name: trackerNameTextfield.text, emojiPic: selectedEmoji, color: selectedColor, schedule: daysToSend)
            try? trackerStore.editTrackerInCoreData(tempTracker)
            guard let trackerID = tempTracker.id, let selectedCategoryName else { return }
            trackerStore.changeTrackerCategories(by: trackerID, newCategoryTitle: selectedCategoryName)
        }
        
        resettingFields()
        self.dismiss(animated: true)
    }
    
    @objc private func editingTrackerName(_ sender: UITextField) {
        guard let text = sender.text else { return }
        trackerNameTextfield.text = text
        canEnableCreateButton()
    }
}

// MARK: UITableViewDelegate
extension NewHabitVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            analyticsService.sendEvent(event: "open", screen: "CreateHabit")
            let viewModel = CategoryVCViewModel()
            let newCategoryVC = CategoryVC(viewModel: viewModel)
            switch habitViewState {
                case .creating:
                    viewModel.categoryVCViewModelState = .creating
                    newCategoryVC.categoryVCState = .creating
                case .editing(tracker: let tracker):
                    viewModel.categoryVCViewModelState = .editing(tracker: tracker)
                    newCategoryVC.categoryVCState = .editing(tracker: tracker)
            }
            viewModel.returnToPreviousViewHandler = { [weak self] selectedCategoryInModel in
                guard let self else { return }
                self.selectedCategoryName = selectedCategoryInModel
                canEnableCreateButton()
                tableView.reloadData()
                self.navigationController?.popViewController(animated: true)
            }
                navigationController?.pushViewController(newCategoryVC, animated: true)
        } else {
            analyticsService.sendEvent(event: "open", screen: "CreateHabit")
            let scheduleVC = ScheduleVC()
            if daysToSend.isEmpty {
                scheduleVC.scheduleViewState = .creating
            } else {
                scheduleVC.scheduleViewState = .editing(daysToSend)
            }
            navigationController?.pushViewController(scheduleVC, animated: true)
            scheduleVC.tappedReady = { [weak self] (wdArray) -> Void in
                guard let self else { return }
                daysString = intsToDaysOfWeek(dayArray: wdArray)
                canEnableCreateButton()
                tableView.reloadData()
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: UITableViewDataSource
extension NewHabitVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "tableCell")
        if indexPath.row == 0 {
            categoryCell = cell
            categoryCell.detailTextLabel?.text = selectedCategoryName ?? trackerCategoryPlaceholder
        } else {
            scheduleCell = cell
            scheduleCell.detailTextLabel?.text = daysString ?? trackerWeekdayPlaceholder
        }
        cell.textLabel?.text = buttonNameArray[indexPath.row].0
        cell.detailTextLabel?.textColor = .ypGray
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.detailTextLabel?.font = .systemFont(ofSize: 17)
        cell.backgroundColor = .ypBackground
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

// MARK: UITextFieldDelegate
extension NewHabitVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        trackerNameTextfield.resignFirstResponder()
        return true
    }
}

// MARK: UICollectionViewDataSource, UICollectionViewDelegate

extension NewHabitVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellEmojiAndColors", for: indexPath) as! CellCollectionViewController
        switch indexPath.section {
        case 0:
            collectionViewCell.setEmojiImage(text: "\(emojis[indexPath.row])")
            collectionViewCell.setCellSize(size: ((collectionView.bounds.width - 25) / 6), section: 0)
            switch habitViewState {
            case .creating:
                collectionViewCell.emojiLabel.backgroundColor = .clear
            case .editing(let tracker):
                if tracker.emojiPic == "\(emojis[indexPath.row])" {
                    collectionViewCell.setImageViewColor(section: 0)
                    selectedEmoji = emojis[indexPath.item]
                    selectedEmojiCell = collectionViewCell
                    emojiSelected = true
                    selectedIndexPaths[indexPath.section] = indexPath
                } else {
                    collectionViewCell.emojiLabel.backgroundColor = .clear
                }
            }
        case 1:
            collectionViewCell.setItemColor(color: colors[indexPath.row])
            collectionViewCell.setCellSize(size: ((collectionView.bounds.width - 25) / 6), section: 1)
            switch habitViewState {
            case .creating: break
            case .editing(let tracker):
                if tracker.color == colors[indexPath.row] {
                    collectionViewCell.setImageViewColor(section: 1)
                    selectedColor = colors[indexPath.item]
                    selectedColorCell = collectionViewCell
                    colorSelected = true
                    selectedIndexPaths[indexPath.section] = indexPath
                }
            }
        default:
            return CellCollectionViewController()
        }
        canEnableCreateButton()
        return collectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let previouslySelectedIndexPath = selectedIndexPaths[indexPath.section] {
            collectionView.deselectItem(at: previouslySelectedIndexPath, animated: true)
            selectedIndexPaths[indexPath.section] = nil
            if let cell = collectionView.cellForItem(at: previouslySelectedIndexPath) as? CellCollectionViewController {
                cell.unsetImageViewColor(section: indexPath.section) // unsetting cell BG if selected
            }
        }
        // Select new item, update tracking
        selectedIndexPaths[indexPath.section] = indexPath
        if let cell = collectionView.cellForItem(at: indexPath) as? CellCollectionViewController {
            cell.setImageViewColor(section: indexPath.section) // setting selected cell BG
            if indexPath.section == 0 {
                selectedEmoji = emojis[indexPath.item]
                selectedEmojiCell = cell
                emojiSelected = true
            } else {
                selectedColor = colors[indexPath.item]
                selectedColorCell = cell
                colorSelected = true
            }
        }
        canEnableCreateButton()
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let id = "header"
        var headerText: String = ""
        let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! SupplementaryHeaderView
        if indexPath.section == 0 {
            headerText = "Emoji"
        } else {
            headerText = headerTextForColor
        }
        supplementaryView.headerLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        supplementaryView.headerLabel.text = headerText
        supplementaryView.systemLayoutSizeFitting(CGSize(width: supplementaryView.frame.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
        return supplementaryView
    }
}

extension NewHabitVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = (collectionView.bounds.width - 25) / 6
        return CGSize(width: cellSize, height: cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 0, bottom: 16, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 36)
    }
}

