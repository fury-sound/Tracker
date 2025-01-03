//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Valery Zvonarev on 26.12.2024.
//

import UIKit

//final class CategoryVCViewModel: AddCategoryViewModelDelegate {
final class CategoryVCViewModel {
    
    var counter = 0
    
    let trackerCategoryStore = TrackerCategoryStore()

    var trackerNameArray: [String] = [] {
        didSet {
            print("changed", counter)
            counter += 1
            trackerCategoryStore.countEntities()
        }
    }
    
    var createButtonNameInModel: String? {
        didSet {
//            print("in didSet, createButtonNameInModel")
//            buttonTitle()
            buttonNameChange?(createButtonNameInModel!)
        }
    }
    
    var selectedIndex: Int? {
        didSet {
//            buttonNameChange?(createButtonNameInModel)
            reloadDataHandler?()
        }
    }
    
    var selectedCategoryName: String = "" {
        didSet {
//            sendCategoryHandler?()
//            print("in CategoryVCViewModel name:", selectedCategoryName)
//            guard var trackerNameArray else {return}
//            print("добавили \(selectedCategoryName)? - ", trackerNameArray)
//            sendCategoryHandler?(selectedCategoryName)
//            trackerNameArray.append(selectedCategoryName)
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
    }
    
    func retrieveAllTrackerCategories() {
        trackerNameArray = trackerCategoryStore.retrieveAllTrackerCategoryTitles()
    }
    
    func didSelectCategoryAtIndex(index: Int) {
//        print("index", index)
        if selectedIndex == index {
            selectedIndex = nil
        } else {
            selectedIndex = index
        }
        createButtonNameInModel = (selectedIndex == nil ? "Создать категорию" : "Добавить категорию")
    }
    
    func categoryCreateButtonTapped() {
        print("AddCategoryVC button tapped")
        if let selectedIndex {
            returnToPreviousViewHandler?(trackerNameArray[selectedIndex])
        } else {
            addCategoryVCHandler?()
        }
    }
    
    func sendingCategoryToPreviousVC(name: String) {
        selectedCategoryName = name
    }

}

