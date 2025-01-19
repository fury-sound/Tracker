//
//  CategoryVC.swift
//  Tracker
//
//  Created by Valery Zvonarev on 14.11.2024.
//

import UIKit

final class CategoryVC: UIViewController {
    
    private let viewModel: CategoryVCViewModel
    
    private lazy var imageView: UIImageView = {
        let image = UIImage.flyingStar
        let imageView = UIImageView(image: image)
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    private lazy var initSlogan: UILabel = {
        let initSlogan = UILabel()
        initSlogan.backgroundColor = .clear
        initSlogan.numberOfLines = 2
        initSlogan.text = initSloganText
        initSlogan.textAlignment = .center
        initSlogan.font = .systemFont(ofSize: 12, weight: .medium)
        initSlogan.textColor = .ypBlack
        initSlogan.sizeToFit()
        return initSlogan
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let addCategoryButton = UIButton()
        addCategoryButton.layer.cornerRadius = 16
        addCategoryButton.backgroundColor = TrackerColors.backgroundButtonColor
        addCategoryButton.setTitleColor(TrackerColors.buttonTintColor, for: .normal)
        addCategoryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        addCategoryButton.addTarget(self, action: #selector(addCategory), for: .touchUpInside)
        return addCategoryButton
    }()
    
    private lazy var categoryTableView: UITableView = {
        let categoryTableView = UITableView(frame: .zero, style: .insetGrouped)
        categoryTableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableCell")
        categoryTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 1))
        categoryTableView.backgroundColor = .clear
        categoryTableView.isScrollEnabled = true
        categoryTableView.allowsMultipleSelection = false
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        categoryTableView.separatorStyle = .singleLine
        categoryTableView.separatorInset.left = 16
        categoryTableView.separatorInset.right = 16
        categoryTableView.layer.cornerRadius = 16
        categoryTableView.layer.masksToBounds = true
        categoryTableView.clipsToBounds = true
        return categoryTableView
    }()
    
    var addCategoryState: viewControllerForCategoryState = .creating {
        didSet {
        }
    }
    
    var categoryVCState: viewControllerState = .creating {
        didSet {
        }
    }
    
    init(viewModel: CategoryVCViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = categoryTitle
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewDidLoad()
        imageView.isHidden = !viewModel.trackerNameArray.isEmpty
        initSlogan.isHidden = !viewModel.trackerNameArray.isEmpty
        viewModel.trackerNameArray.isEmpty ? setupEmptyVC() : setupVCWithTable()
    }
    
    private func setupVCWithTable() {
        let elementArray = [categoryTableView, addCategoryButton]
        elementArray.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        NSLayoutConstraint.activate([
            categoryTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categoryTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            categoryTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoryTableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupEmptyVC() {
        let elementArray = [imageView, initSlogan, addCategoryButton]
        elementArray.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            initSlogan.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            initSlogan.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func viewSetup() {
        view.backgroundColor = TrackerColors.viewBackgroundColor
        viewModel.trackerNameArray.isEmpty ? setupEmptyVC() : setupVCWithTable()
        let addCategoryViewModel = AddCategoryViewModel()
        addCategoryViewModel.settingNewCategoryName = { [weak self] newCategoryName in
            self?.viewModel.selectedCategoryName = newCategoryName
        }
        
        viewModel.addCategoryVCHandler = { [weak self] in
            guard let self else { return }
            switch addCategoryState {
            case .creating:
                let addCategoryVC = AddCategoryVC(viewModel: addCategoryViewModel)
                addCategoryViewModel.addCategoryVCViewModelState = .creating
                addCategoryVC.addCategoryVCState = .creating
                self.navigationController?.pushViewController(addCategoryVC, animated: true)
            case .editing(let existingCategoryName):
                let editCategoryVC = AddCategoryVC(viewModel: addCategoryViewModel)
                addCategoryViewModel.addCategoryVCViewModelState = .editing(existingCategoryName: existingCategoryName)
                editCategoryVC.addCategoryVCState = .editing(existingCategoryName: existingCategoryName)
                self.navigationController?.pushViewController(editCategoryVC, animated: true)
            }
        }
        
        viewModel.setCreatForAddCategoryVCState = { [weak self] in
            guard let self else { return }
            self.addCategoryState = .creating
        }
        
        viewModel.setEditForAddCategoryVCState = { [weak self] categoryName in
            guard let self else { return }
            self.addCategoryState = .editing(existingCategoryName: categoryName)
        }
        
        viewModel.reloadDataHandler = { [weak self] in
            self?.categoryTableView.reloadData()
        }
        
        viewModel.buttonNameChange = { [weak self] buttonTitle in
            self?.addCategoryButton.setTitle(buttonTitle, for: .normal)
        }
        
        viewModel.lockTableFromChanges = { [weak self] in
            guard let self else { return }
            self.categoryTableView.isUserInteractionEnabled = false
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableTappedAlert))
            view.addGestureRecognizer(tapGesture)
        }
        
    }
    
    @objc func addCategory() {
        viewModel.categoryCreateButtonTapped()
    }
    
    @objc func tableTappedAlert() {
        let alert = UIAlertController(title: alertTitleForCategory, message: changingPinnedCategory, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true)
    }
    
    @objc func deleteCategoryAlert(categoryName: String) {
        let alert = UIAlertController(title: alertTitleForCategory, message: deletingCategory, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: deleteText, style: .destructive, handler: { [weak self] _ in
            self?.viewModel.deleteCategoryActionTapped(categoryName: categoryName)
        }))
        alert.addAction(UIAlertAction(title: cancelText, style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: UITableViewDelegate
extension CategoryVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let cell = tableView.cellForRow(at: indexPath)
        guard let existingCategoryName = cell?.textLabel?.text else { return nil }
        if indexPath.row == 0 {
            tableTappedAlert()
            return nil
        }
        return UIContextMenuConfiguration(actionProvider: { actions in
            return UIMenu(title: "Options", children: [
                UIAction(title: editActionText, image: UIImage(systemName: "pencil")) { [weak self] _ in
                    guard let self else { return }
                    viewModel.editCategoryActionTapped(startCategoryName: existingCategoryName)
                },
                UIAction(title: deleteActionText, image: UIImage(systemName: "scissors"), attributes: .destructive) { [weak self] _ in
                    guard let self else { return }
                    self.deleteCategoryAlert(categoryName: existingCategoryName)
                }
            ])
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectCategoryAtIndex(index: indexPath.item)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.row == 0 {
            return nil
        }
        return indexPath
    }
}

// MARK: UITableViewDataSource
extension CategoryVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.trackerNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell")
        let usedArray = viewModel.trackerNameArray
        guard let cell else { return UITableViewCell()}
        cell.selectionStyle = .none
        cell.textLabel?.text = usedArray[indexPath.row]
        cell.textLabel?.textColor = TrackerColors.backgroundButtonColor
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.backgroundColor = .ypBackground
        
        if let selectedIndex = viewModel.selectedIndex, indexPath.row == selectedIndex {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
}
