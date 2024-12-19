//
//  NewEventVC.swift
//  Tracker
//
//  Created by Valery Zvonarev on 18.12.2024.
//

import UIKit

final class NewEventVC: UIViewController {
    
    var daysToSend = [ScheduledDays]()
    private let buttonNameArray = [("Категория", "Название категории")]
    private var categoryCell = UITableViewCell()
//    private var scheduleCell = UITableViewCell()
    private var defaultHeader = "Трекеры по умолчанию"
    private var textInTextfield = ""
    private let params = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    private var selectedEmoji = "🙂"
    private var selectedColor: UIColor = .ypDarkRed
    private let layout = UICollectionViewFlowLayout()
    let trackerStore = TrackerStore()

    
    private let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🫢", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
        
    private let colors = Colors
    private var selectedIndexPaths: [Int: IndexPath] = [:]
    
    private lazy var eventNameTextfield: UITextField = {
        var eventNameTextfield = UITextField()
        eventNameTextfield.backgroundColor = .ypLightGray
        eventNameTextfield.layer.cornerRadius = 16
        eventNameTextfield.clearButtonMode = .whileEditing
        eventNameTextfield.placeholder = "Введите название привычки"
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 20))
        eventNameTextfield.leftView = paddingView
        eventNameTextfield.leftViewMode = .always
        eventNameTextfield.delegate = self
        eventNameTextfield.addTarget(self, action: #selector(editingEventName(_ :)), for: .editingChanged)
        return eventNameTextfield
    }()
    
    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.backgroundColor = .ypWhite
        cancelButton.layer.cornerRadius = 16
        cancelButton.setTitleColor(.ypRed, for: .normal)
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        cancelButton.layer.borderColor = UIColor.ypRed.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.addTarget(self, action: #selector(cancelEventCreation), for: .touchUpInside)
        return cancelButton
    }()
    
    private lazy var createButton: UIButton = {
        let createButton = UIButton()
        createButton.layer.cornerRadius = 16
        createButton.backgroundColor = .ypGray
        createButton.isEnabled = false
        createButton.setTitleColor(.ypWhite, for: .normal)
        createButton.setTitle("Создать", for: .normal)
        createButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        createButton.addTarget(self, action: #selector(createEvent), for: .touchUpInside)
        return createButton
    }()
    
    private lazy var buttonTableView: UITableView = {
        let buttonTableView = UITableView()
        buttonTableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableCell")
        buttonTableView.backgroundColor = .ypLightGray
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
//        scrollView.showsVerticalScrollIndicator = true
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    //    layout.headerReferenceSize
    
    private lazy var emojiCollectionView: UICollectionView = {
        //        layout.scrollDirection = .vertical
        //        layout.minimumInteritemSpacing = 5
        let emojiAndColorsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        emojiAndColorsCollectionView.backgroundColor = .clear
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
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.backgroundColor = .clear
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Новая привычка"
        viewSetup()
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    // MARK: Public functions
    func defaultFields() {
        eventNameTextfield.text = ""
        createButton.isEnabled = false
        categoryCell.detailTextLabel?.text = buttonNameArray[0].1
//        scheduleCell.detailTextLabel?.text = buttonNameArray[1].1
    }
    
    // MARK: Private functions
    private func viewSetup() {
        view.backgroundColor = .ypWhite
        [scrollView, stackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        containingView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(containingView)
        
//        trackerNameTextfield.backgroundColor = .red
//        buttonTableView.backgroundColor = .green
        let containedArray = [eventNameTextfield, buttonTableView, emojiCollectionView]
//        let scrollViewArray = [trackerNameTextfield, buttonTableView]
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
            
            eventNameTextfield.leadingAnchor.constraint(equalTo: containingView.leadingAnchor, constant: 16),
            eventNameTextfield.trailingAnchor.constraint(equalTo: containingView.trailingAnchor, constant: -16),
            eventNameTextfield.topAnchor.constraint(equalTo: containingView.topAnchor, constant: 24),
            eventNameTextfield.heightAnchor.constraint(equalToConstant: 75),
            
            buttonTableView.leadingAnchor.constraint(equalTo: containingView.leadingAnchor, constant: 16),
            buttonTableView.trailingAnchor.constraint(equalTo: containingView.trailingAnchor, constant: -16),
            buttonTableView.topAnchor.constraint(equalTo: eventNameTextfield.bottomAnchor, constant: 24),
            buttonTableView.heightAnchor.constraint(equalToConstant: 74),
            
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
        if (textInTextfield.isEmpty == true || textInTextfield.count > 38) {
            createButton.isEnabled = false
            createButton.backgroundColor = .ypGray
        } else {
            createButton.isEnabled = true
            createButton.backgroundColor = .ypBlack
            categoryCell.detailTextLabel?.text = defaultHeader
        }
    }
    
    // MARK: @objc functions
    @objc private func cancelEventCreation() {
        textInTextfield = ""
        self.dismiss(animated: true)
    }
    
    @objc private func createEvent() {
//        guard let delegateTrackerInNewHabitVC else {
//            debugPrint("no delegate")
//            return
//        }
        guard let eventText = eventNameTextfield.text else { return }
        let idNum = UUID()
//        delegateTrackerInNewHabitVC.getDelegateTracker().addingTrackerOnScreen(trackerName: trackerText, trackerCategory: defaultHeader, emoji: selectedEmoji, color: selectedColor, dateArray: daysToSend)
//        daysToSend = [.Mon, .Tue, .Wed, .Thu, .Fri, .Sat, .Sun]
        daysToSend = []
        let addedEvent = Tracker(id: idNum, name: eventText, emojiPic: selectedEmoji, color: selectedColor, schedule: daysToSend)
        let category = TrackerCategory(title: defaultHeader)
        do {
            try trackerStore.addTrackerToCoreData(addedEvent)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        textInTextfield = ""
        self.dismiss(animated: true)
    }
    
    @objc private func editingEventName(_ sender: UITextField) {
        guard let text = sender.text else { return }
        textInTextfield = text
        canEnableCreateButton()
    }
    
}

// MARK: UITableViewDelegate
extension NewEventVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.row == 1 && cell.detailTextLabel?.text != "Дни недели" {
//            cell.detailTextLabel?.text = "Дни недели"
//        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let categoryVC = CategoryVC()
        navigationController?.pushViewController(categoryVC, animated: true)
    }
}

// MARK: UITableViewDataSource
extension NewEventVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "tableCell")
//        if indexPath.row == 0 {
//            categoryCell = cell
//        } else {
//            scheduleCell = cell
//        }
        cell.textLabel?.text = buttonNameArray[indexPath.row].0
        cell.detailTextLabel?.text = buttonNameArray[indexPath.row].1
        cell.detailTextLabel?.textColor = .ypGray
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.detailTextLabel?.font = .systemFont(ofSize: 17)
        cell.backgroundColor = .ypBackgroundDay
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

// MARK: UITextFieldDelegate
extension NewEventVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        eventNameTextfield.resignFirstResponder()
        return true
    }
}

// MARK: UICollectionViewDataSource, UICollectionViewDelegate

extension NewEventVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
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
            collectionViewCell.emojiLabel.backgroundColor = .clear
            collectionViewCell.setEmojiImage(text: "\(emojis[indexPath.row])")
            collectionViewCell.setCellSize(size: ((collectionView.bounds.width - 25) / 6), section: 0)
        case 1:
            collectionViewCell.setItemColor(color: colors[indexPath.row])
            collectionViewCell.setCellSize(size: ((collectionView.bounds.width - 25) / 6), section: 1)
        default:
//            print("in default")
            return CellCollectionViewController()
        }
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
            } else {
                selectedColor = colors[indexPath.item]
            }
        }
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
            headerText = "Цвет"
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

extension NewEventVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = (collectionView.bounds.width - 25) / 6
        return CGSize(width: cellSize, height: cellSize)
        //        return CGSize(width: (collectionView.bounds.width - 30) / 6, height: 52)
        //        print("ширина", collectionView.bounds.width, collectionView.bounds.width/6, (collectionView.bounds.width-30)/6)
        //        return CGSize(width: 68, height: 68)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        //        return UIEdgeInsets(top: 10, left: params.leftInset, bottom: 10, right: params.rightInset)
        //        return params
        return UIEdgeInsets(top: 24, left: 0, bottom: 16, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 36)
    }
}
