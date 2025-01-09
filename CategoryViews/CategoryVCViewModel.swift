//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Valery Zvonarev on 26.12.2024.
//

import UIKit

//final class CategoryVCViewModel: AddCategoryViewModelDelegate { // to be deleted
final class CategoryVCViewModel {
    
    var counter = 1
    let trackerCategoryStore = TrackerCategoryStore()

    var trackerNameArray: [String] = [] {
        didSet {
            reloadDataHandler?()
        }
    }
    
    var createButtonNameInModel: String? {
        didSet {
            buttonNameChange?(createButtonNameInModel ?? "")
        }
    }
    
    var selectedIndex: Int? {
        didSet {
            reloadDataHandler?()
        }
    }
    
    var selectedCategoryName: String = "" {
        didSet {
            reloadDataHandler?()
        }
    }
    
    var sendCategoryHandler: (() -> Void)?
    
    var addCategoryVCHandler: (() -> Void)?
    
    var returnToPreviousViewHandler: ((String) -> Void)?
    
    var reloadDataHandler: (() -> Void)?
    
    var buttonNameChange: ((String) -> Void)?
    
    func viewDidLoad() {
        createButtonNameInModel = "Создать категорию"
        retrieveAllTrackerCategories()
    }
    
    private func retrieveAllTrackerCategories() {
        trackerNameArray = trackerCategoryStore.retrieveAllTrackerCategoryTitles()
    }
    
    func didSelectCategoryAtIndex(index: Int) {
        if selectedIndex == index {
            selectedIndex = nil
        } else {
            selectedIndex = index
        }
        createButtonNameInModel = (selectedIndex == nil ? "Создать категорию" : "Добавить категорию")
    }
    
    func categoryCreateButtonTapped() {
        if let selectedIndex {
            returnToPreviousViewHandler?(trackerNameArray[selectedIndex])
        } else {
            addCategoryVCHandler?()
        }
    }
}

