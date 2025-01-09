//
//  CategoryVC.swift
//  Tracker
//
//  Created by Valery Zvonarev on 14.11.2024.
//

import UIKit

final class CategoryVC: UIViewController {
    
    private var viewModel: CategoryVCViewModel
    private var prevCell = UITableViewCell()
    
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
        initSlogan.text = "Привычки и события можно \n объединять по смыслу"
        initSlogan.textAlignment = .center
        initSlogan.font = .systemFont(ofSize: 12, weight: .medium)
        initSlogan.textColor = .ypBlack
        initSlogan.sizeToFit()
        return initSlogan
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let addCategoryButton = UIButton()
        addCategoryButton.layer.cornerRadius = 16
        addCategoryButton.backgroundColor = .ypBlack
        addCategoryButton.setTitleColor(.ypWhite, for: .normal)
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
    
    init(viewModel: CategoryVCViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Категория"
//        viewModel.trackerNameArray = ["123", "234"] // mock category title array, to be deleted
        viewSetup()
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewDidLoad()
        if viewModel.trackerNameArray.isEmpty {
            imageView.isHidden = false
            initSlogan.isHidden = false
            setupEmptyVC()
        } else {
            imageView.isHidden = true
            initSlogan.isHidden = true
            setupVCWithTable()
        }
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
        view.backgroundColor = .white
        if viewModel.trackerNameArray.isEmpty {
            setupEmptyVC()
        } else {
            setupVCWithTable()
        }
        let viewModelAddCategory = AddCategoryViewModel()
//        viewModelAddCategory.delegate = viewModel // to be deleted
        
        viewModelAddCategory.settingNewCategoryName = { [weak self] newCategoryName in
            self?.viewModel.selectedCategoryName = newCategoryName
        }

        viewModel.addCategoryVCHandler = { [weak self] in
            guard let self else { return }
            let newAddCategoryVC = AddCategoryVC(viewModel: viewModelAddCategory)
            self.navigationController?.pushViewController(newAddCategoryVC, animated: true)
        }
        
        viewModel.reloadDataHandler = { [weak self] in
            self?.categoryTableView.reloadData()
        }
        
        viewModel.buttonNameChange = { [weak self] buttonTitle in
            self?.addCategoryButton.setTitle(buttonTitle, for: .normal)
        }
    }
    
    @objc func addCategory() {
        viewModel.categoryCreateButtonTapped()
    }


}

// MARK: UITableViewDelegate
extension CategoryVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        viewModel.didSelectCategoryAtIndex(index: -1)
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectCategoryAtIndex(index: indexPath.row)
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
        cell.textLabel?.textColor = .ypBlack
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.backgroundColor = .ypBackgroundDay

        if let selectedIndex = viewModel.selectedIndex, indexPath.row == selectedIndex {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
}
