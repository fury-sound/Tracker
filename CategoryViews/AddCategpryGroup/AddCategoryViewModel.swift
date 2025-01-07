//
//  AddCategoryViewModel.swift

//  Tracker
//
//  Created by Valery Zvonarev on 26.12.2024.
//

import Foundation
import UIKit

//protocol AddCategoryViewModelDelegate: AnyObject {
//    var selectedCategoryName: String { get set }
//}

final class AddCategoryViewModel {
    
//    weak var delegate: AddCategoryViewModelDelegate?
    let trackerCategoryStore = TrackerCategoryStore()
    
    private var buttonEnabled: Bool = false {
        didSet {
            editTextFieldHandler?(buttonEnabled)
        }
    }
    
    var newCategoryName: String = "" {
        didSet {
//            delegate?.selectedCategoryName = newCategoryName
            settingNewCategoryName?(newCategoryName)
        }
    }
    
    var editTextFieldHandler: ((Bool) -> Void)?
    
//    var creatingNewCategoryHandler: ((String) -> Void)?
    
    var settingNewCategoryName: ((String) -> Void)?
    
    var errorCreatingNewCategory: ((String) -> Void)?
    
    func creatingNewCategoryTapped(name: String) {
        print("creatingNewCategoryTapped tapped")

        if !trackerCategoryStore.isCategoryAlreadyExist(categoryName: name) {
            newCategoryName = name
            do {
                try trackerCategoryStore.addTrackerCategoryTitleToCoreData(newCategoryName)
            } catch let error as NSError {
                debugPrint("Error creating new category: \(error)")
            }
        } else {
            print("Категория с таким именем уже существует")
            errorCreatingNewCategory?(name)
        }
    }
    
//    func checkAndUpdateTrackerCategoryInCoreData() {
//        do {
//            if !trackerCategoryStore.isCategoryAlreadyExist(categoryName: newCategoryName) {
//                try trackerCategoryStore.addTrackerCategoryToCoreData(TrackerCategory(title: newCategoryName))
//            }
//        } catch let error as NSError {
//            print(error.localizedDescription)
//        }
//    }
    
    func onEditingTextField(text: String) {
        //        print("editing TextField for Category Name")
        buttonEnabled = !text.isEmpty
    }
    
    func viewDidLoad() {
        buttonEnabled = false
    }
    
}
