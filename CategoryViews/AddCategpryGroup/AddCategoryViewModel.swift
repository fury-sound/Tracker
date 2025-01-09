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
    let trackerCategoryStore = TrackerCategoryStore()
    
    private var buttonEnabled: Bool = false {
        didSet {
            editTextFieldHandler?(buttonEnabled)
        }
    }
    
    var newCategoryName: String = "" {
        didSet {
//            delegate?.selectedCategoryName = newCategoryName // to be deleted
            settingNewCategoryName?(newCategoryName)
        }
    }
    
    var editTextFieldHandler: ((Bool) -> Void)?
        
    var settingNewCategoryName: ((String) -> Void)?
    
    var errorCreatingNewCategory: ((String) -> Void)?
    
    func creatingNewCategoryTapped(name: String) {
        if !trackerCategoryStore.isCategoryAlreadyExist(categoryName: name) {
            newCategoryName = name
            do {
                try trackerCategoryStore.addTrackerCategoryTitleToCoreData(newCategoryName)
            } catch let error as NSError {
                print("Error creating new category: \(error)")
            }
        } else {
            errorCreatingNewCategory?(name)
        }
    }
    
    func onEditingTextField(text: String) {
        buttonEnabled = !text.isEmpty
    }
    
    func viewDidLoad() {
        buttonEnabled = false
    }
    
}
