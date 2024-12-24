//
//  CategoryViewAssembler.swift
//  Tracker
//
//  Created by Valery Zvonarev on 23.12.2024.
//

import UIKit

final class CategoryViewAssembler {
    
    class func buildCategoryModule(navigationController: UINavigationController) -> CategoryView {
        let viewModel = CategoryViewModelImpl()
        viewModel.addCategoryButtonTap = {
            let addCategoryView = AddCategoryVC()
            navigationController.pushViewController(addCategoryView, animated: true)
        }
        let categoryView = CategoryView(viewModel: viewModel)
        
        return categoryView
    }
}
