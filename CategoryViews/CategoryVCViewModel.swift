//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Valery Zvonarev on 26.12.2024.
//

import UIKit

//final class CategoryVCViewModel: AddCategoryViewModelDelegate { // to be deleted
final class CategoryVCViewModel {
    
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerStore = TrackerStore()
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
            print("addCategoryVCViewModelState", addCategoryVCViewModelState)
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
                print("selectedCategoryName", selectedCategoryName)
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
//    var updateAddCategoryState: StringClosure?
    
//    addCategoryState = .editing(existingCategoryName: tracker.name)
    
    //    var sendCategoryHandler: (() -> Void)? // never called
    //    var addCategoryVCHandler: (() -> Void)?
    //    var returnToPreviousViewHandler: ((String) -> Void)?
    //    var reloadDataHandler: (() -> Void)?
    //    var buttonNameChange: ((String) -> Void)?
    
    func viewDidLoad() {
        retrieveAllTrackerCategories()
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
    
    private func retrieveAllTrackerCategories() {
        print(trackerCategoryStore.retrieveAllTrackerCategoryTitles())
        trackerNameArray = trackerCategoryStore.retrieveAllTrackerCategoryTitles()
    }
        
    func editCategoryActionTapped(startCategoryName: String) {
        print("edit category: \(startCategoryName)") // to \(targetCategoryName)")
        addCategoryVCViewModelState = .editing(existingCategoryName: startCategoryName)
        addCategoryVCHandler?()
        retrieveAllTrackerCategories()
        reloadDataHandler?()
    }

// TO BE DELETED. Тест редактирование категории через UIAlert
//    func editCategoryActionAlertTapped(startCategoryName: String, targetCategoryName: String) {
//        print("edit category: \(startCategoryName) to \(targetCategoryName)")
//        trackerCategoryStore.changeTrackerCategoryName(startCategory: startCategoryName, targetCategory: targetCategoryName)
//        retrieveAllTrackerCategories()
//        reloadDataHandler?()
//    }

    func deleteCategoryActionTapped(categoryName: String) {
        print("delete category: '\(categoryName)'")

    }
    
    func updateCategoryVCUIForState(_ state: viewControllerState) {
        //        switch categoryVCState {
        //        case .editing(let tracker):
        //            viewModel(state: editing)
        ////            createOrSaveButton.setTitle(saveButtonText, for: .normal)
        //////            createOrSaveButton.isEnabled = true
        ////            setEditedTrackersData(tracker: tracker)
        //
        //        case .creating:
        //            viewModel(state: .creating)
        //            defaultFields()
        ////            categoryViewTitle = newTrackerTitle
        ////            createOrSaveButton.setTitle(createButtonText, for: .normal)
        //        }
    }
    
    func didSelectCategoryAtIndex(index: Int) {
        //        if selectedIndex == index {
        //            selectedIndex = nil
        //        } else {
        //            selectedIndex = index
        //        }
        selectedIndex = (selectedIndex == index) ? nil : index
        print("selectedIndex", selectedIndex)
        switch categoryVCViewModelState {
        case .creating:
            print("in creating")
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

