//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Valery Zvonarev on 26.12.2024.
//

import UIKit

final class CategoryVCViewModel {
    
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    private var selectedCategoryVCTitle: String?

    private var createButtonNameInModel: String? {
        didSet {
            buttonNameChange?(createButtonNameInModel ?? "")
        }
    }
    
    var categoryVCViewModelState: viewControllerState = .creating {
        didSet {
//            guard let selectedCategoryVCTitle else { return }
//            print("selectedCategoryVCTitle", selectedCategoryVCTitle)
//            updateCategoryVCUIForState?(selectedCategoryVCTitle)
        }
    }
    
    var addCategoryVCViewModelState: viewControllerForCategoryState = .creating {
        didSet {
            switch addCategoryVCViewModelState {
            case .creating:
                setCreatForAddCategoryVCState?()
            case .editing(let existingCategoryName):
                setEditForAddCategoryVCState?(existingCategoryName)
            }
        }
    }
    
    var trackerNameArray: [String] = [] {
        didSet {
            reloadDataHandler?()
        }
    }
    
    var selectedIndex: Int? {
        didSet {
            reloadDataHandler?()
        }
    }
    
    var selectedCategoryName: String = "" {
        didSet {
            switch categoryVCViewModelState {
            case .creating:
                reloadDataHandler?()
            case .editing(let tracker):
                if selectedCategoryName == "Pinned" {
                    lockTableFromChanges?()
                }
            }
        }
    }
    
    typealias EmptyClosure = () -> Void
    typealias StringClosure = (String) -> Void
    //    typealias UIStateClosure = (viewControllerState) -> Void
    
    /// Используется для установеи состояния addCategoryState как creaing
    var setCreatForAddCategoryVCState: EmptyClosure?

    /// Используется для установеи состояния addCategoryState как editing
    var setEditForAddCategoryVCState: StringClosure?

    /// Используется для определения состояния addCategoryState (creaing/editing) и настроек модуля добавления категории
    var addCategoryVCHandler: EmptyClosure?
    
    /// просто перезагрузка твблицы
    var reloadDataHandler: EmptyClosure?
    
    /// возврат данных в окно NewHabitVC/NewEventVC
    var returnToPreviousViewHandler: StringClosure?
    
    /// изменение надписи на кнопке addCategoryButton в зависимости от состояния (creaing/editing)
    var buttonNameChange: StringClosure?
    
    /// при выборе трекера из категории Pinned для редактирования не дает взаимодействовать с таблицей категорий
    var lockTableFromChanges: EmptyClosure?
    
    func viewDidLoad() {
        retrieveAllTrackerCategoriesToTable()
        switch categoryVCViewModelState {
        case .creating:
            createButtonNameInModel = createCategoryText
            selectedCategoryVCTitle = newTrackerTitle
        case .editing(tracker: let tracker):
            guard let trackerID = tracker.id else { return }
            
            selectedCategoryVCTitle = editTrackerTitle
            createButtonNameInModel = changeCategoryText
            selectedCategoryName = trackerStore.retrieveTrackerCategoryByID(by: trackerID) ?? ""
            selectedIndex = trackerNameArray.firstIndex(of: selectedCategoryName)
        }
    }
    
    private func retrieveAllTrackerCategoriesToTable() {
        trackerNameArray = trackerCategoryStore.retrieveAllTrackerCategoryTitles()
    }
        
    func editCategoryActionTapped(startCategoryName: String) {
        addCategoryVCViewModelState = .editing(existingCategoryName: startCategoryName)
        addCategoryVCHandler?()
        retrieveAllTrackerCategoriesToTable()
        reloadDataHandler?()
    }

    func deleteCategoryActionTapped(categoryName: String) {
        let completedTrackersArrayFromPinned = trackerCategoryStore.retrieveTrackerForCategoryByNameForPinned(categoryName: categoryName)
        let completedTrackersArrayFromCategory = trackerCategoryStore.retrieveTrackerForCategoryByName(categoryName: categoryName)
        completedTrackersArrayFromCategory?.forEach {
            trackerRecordStore.deleteTrackerRecordByID(by: $0)
            trackerStore.deleteTracker(by: $0)
        }
        completedTrackersArrayFromPinned?.forEach {
            trackerRecordStore.deleteTrackerRecordByID(by: $0)
            trackerStore.deleteTracker(by: $0)
        }
        trackerCategoryStore.deleteTrackerCategoryName(categoryName: categoryName)
        retrieveAllTrackerCategoriesToTable()
        selectedIndex = nil
        reloadDataHandler?()
    }
  
    // to be deleted
    private func showAllTrackersData() {
//        print("All data for trackers:")
//        print(trackerStore.retrieveAllTrackers())
//        trackerCategoryStore.retrieveCategoryTitles()
//        trackerRecordStore.retrieveAllTrackerRecordCoreDataInfo()
    }
    
    func didSelectCategoryAtIndex(index: Int) {

        selectedIndex = (selectedIndex == index) ? nil : index
        switch categoryVCViewModelState {
        case .creating:
            createButtonNameInModel = (selectedIndex == nil ? createCategoryText : addCategoryText)
        case .editing(let tracker):
            createButtonNameInModel = (selectedIndex == nil ? createCategoryText : changeCategoryText)
        }
    }
    
    func categoryCreateButtonTapped() {
        addCategoryVCViewModelState = .creating
        if let selectedIndex {
            returnToPreviousViewHandler?(trackerNameArray[selectedIndex])
        } else {
            addCategoryVCHandler?()
        }
    }
}

