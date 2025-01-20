//
//  AddCategoryViewModel.swift

//  Tracker
//
//  Created by Valery Zvonarev on 26.12.2024.
//

import Foundation
import UIKit

// to be deleted
//protocol AddCategoryViewModelDelegate: AnyObject {
//    var selectedCategoryName: String { get set }
//}

final class AddCategoryViewModel {
    
//    weak var delegate: AddCategoryViewModelDelegate? // to be deleted
    private let trackerCategoryStore = TrackerCategoryStore()
    
    var addCategoryVCViewModelState: ViewControllerForCategoryState = .creating {
        didSet {
//            guard let selectedCategoryVCTitle else { return }
//            print("selectedCategoryVCTitle", selectedCategoryVCTitle)
//            updateCategoryVCUIForState?(selectedCategoryVCTitle)
//            updateUIParameters()
        }
    }
    
    private var buttonEnabled: Bool = false {
        didSet {
            editTextFieldHandler?(buttonEnabled)
        }
    }
    
    private var newCategoryName: String = "" {
        didSet {
//            delegate?.selectedCategoryName = newCategoryName // to be deleted
            settingNewCategoryName?(newCategoryName)
        }
    }
        
    var editTextFieldHandler: BoolClosure?
    var settingNewCategoryName: StringClosure?
    var errorCreatingNewCategory: StringClosure?
    var updateAddCategoryVCUIForState: StringClosure?
    
//    var editTextFieldHandler: ((Bool) -> Void)?
//    var settingNewCategoryName: ((String) -> Void)?
//    var errorCreatingNewCategory: ((String) -> Void)?
    
    private func updateUIParameters() {
        switch addCategoryVCViewModelState {
        case .creating:
            buttonEnabled = false
            updateAddCategoryVCUIForState?("")
        case .editing(let categoryName):
            buttonEnabled = true
            updateAddCategoryVCUIForState?(categoryName)
        }
    }
    
    func readyCategoryTapped(targetCategoryName: String) {
        switch addCategoryVCViewModelState {
        case .creating:
            if !trackerCategoryStore.isCategoryAlreadyExist(categoryName: targetCategoryName) {
                newCategoryName = targetCategoryName
                do {
                    try trackerCategoryStore.addTrackerCategoryTitleToCoreData(newCategoryName)
                } catch let error as NSError {
                    print("Error creating new category: \(error)")
                }
            } else {
                errorCreatingNewCategory?(targetCategoryName)
            }
        case .editing(let existingCategoryName):
            trackerCategoryStore.changeTrackerCategoryName(startCategory: existingCategoryName, targetCategory: targetCategoryName)
        }
    }
    
    func onEditingTextField(text: String) {
        buttonEnabled = !text.isEmpty
    }
    
    func viewDidLoad() {
        updateUIParameters()
    }
    
}
