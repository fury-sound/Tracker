//
//  CategoryVC.swift
//  Tracker
//
//  Created by Valery Zvonarev on 14.11.2024.
//

import UIKit

final class CategoryVC: UIViewController {
    
    private var viewModel: CategoryVCViewModel
//    var createButtonName: String? //= "Создать категорию"
//    var createButtonName: String? {
//        willSet {
//            addCategoryButton.setTitle(createButtonName, for: .normal)
//        }
//    }
    
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
//        addCategoryButton.setTitle(createButtonName, for: .normal)
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
//        viewModel.trackerNameArray = ["123", "234"]
//        print(viewModel.createButtonNameInModel)
//        addCategoryButton.setTitle(viewModel.createButtonNameInModel, for: .normal)
        viewSetup()
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewDidLoad()
        print(viewModel.trackerNameArray)
        print("imageView.isHidden", imageView.isHidden)
        if viewModel.trackerNameArray.isEmpty {
            print("1")
            imageView.isHidden = false
            initSlogan.isHidden = false
            setupEmptyVC()
        } else {
            print("in viewWillAppear 2")
            imageView.isHidden = true
            initSlogan.isHidden = true
            setupVCWithTable()
//            categoryTableView.reloadData()
        }
    }
    
    private func setupVCWithTable() {
        let elementArray = [categoryTableView, addCategoryButton]
        elementArray.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
//        guard let navItemBottom = navigationItem.titleView?.bounds.b view.bottomAnchor else { return }
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
//            print("1")
            setupEmptyVC()
        } else {
//            print("2")
//            print(viewModel.trackerNameArray)
            setupVCWithTable()
        }

        let viewModelAddCategory = AddCategoryViewModel()
//        createButtonName = viewModel.createButtonNameInModel
        
//        viewModelAddCategory.delegate = viewModel
        viewModelAddCategory.settingNewCategoryName = { [weak self] newCategoryName in
//            print(self?.viewModel.trackerNameArray)
            self?.viewModel.trackerNameArray.append(newCategoryName)
//            print(self?.viewModel.trackerNameArray)
            self?.viewModel.selectedCategoryName = newCategoryName
        }

        viewModel.addCategoryVCHandler = { [weak self] in
            guard let self else { return }
            let newAddCategoryVC = AddCategoryVC(viewModel: viewModelAddCategory)
            self.navigationController?.pushViewController(newAddCategoryVC, animated: true)
//            print(newAddCategoryVC.viewModel.categoryName)
        }
        
        viewModel.reloadDataHandler = { [weak self] in
//            print("reloadData called")
            self?.categoryTableView.reloadData()
        }
        
        viewModel.buttonNameChange = { [weak self] buttonTitle in
//            print("Button name \(buttonTitle)")
            self?.addCategoryButton.setTitle(buttonTitle, for: .normal)
        }
        
        
        
//        viewModel.buttonNameChange = { [weak self] buttonTitle in
//            print("Button name \(buttonTitle)")
//            
//            self?.addCategoryButton.setTitle(buttonTitle, for: .normal)
//        }
        
//        addCategoryButton.setTitle("Добавить категорию", for: .normal)
//        print("before viewModel.sendCategoryHandler")
//        viewModel.sendCategoryHandler = { [weak self] in
//            guard let self else { return }
//            print("in viewModel.sendCategoryHandler")
////            self.viewModel.selectedCategoryName = viewModelAddCategory.newCategoryName
//        }
    }
    
    @objc func addCategory() {
        viewModel.categoryCreateButtonTapped()
//        let addCategoryVC = AddCategoryVC()
//        navigationController?.pushViewController(addCategoryVC, animated: true)
    }

    private var prevCell = UITableViewCell()
//    private var newCategoryNameToBeUsed: String = ""

}

// MARK: UITableViewDelegate
extension CategoryVC: UITableViewDelegate {
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.row == 1 && cell.detailTextLabel?.text != "Дни недели" {
//            cell.detailTextLabel?.text = "Дни недели"
//        }
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        viewModel.didSelectCategoryAtIndex(index: -1)
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        viewModel.didSelectCategoryAtIndex(index: indexPath.row)
        //        let curCell = tableView.cellForRow(at: indexPath)
//        print("indexPath.row", indexPath.row)
//        guard let curCell else { return }
//        curCell.accessoryType = .checkmark
//        newCategoryNameToBeUsed = curCell.textLabel?.text ?? ""
//        prevCell = curCell

//        if curCell.accessoryType == .none {
//            curCell.accessoryType = .checkmark
//        } else {
//            curCell.accessoryType = .none
//        }
        
        
//        tableView.reloadData()

//        if indexPath.row == 0 {
//            let viewModel = CategoryVCViewModel()
////            viewModel.handler = { selectedCategory in
////                self.selectedCategory = selectedCategpory
////            }
////            viewModel.sendCategoryHandler = { selectedCategoryName in
////                nameSec = "name"
////                print(selectedCategoryName)
////            }
//            let categoryVC = CategoryVC(viewModel: viewModel)
//            navigationController?.pushViewController(categoryVC, animated: true)
//            let curCell = tableView.cellForRow(at: indexPath)
//            curCell?.detailTextLabel?.text = nameSec
//        } else {
//            let scheduleVC = ScheduleVC()
//            navigationController?.pushViewController(scheduleVC, animated: true)
//            let curCell = tableView.cellForRow(at: indexPath)
//            curCell?.detailTextLabel?.text = buttonNameArray[indexPath.row].1
//            scheduleVC.tappedReady = { [weak self] (wdArray) -> Void in
//                guard let self else { return }
//                let daysString = intsToDaysOfWeek(dayArray: wdArray)
//                let curCell = tableView.cellForRow(at: indexPath)
//                canEnableCreateButton(dateArray: daysToSend)
//                curCell?.detailTextLabel?.text = daysString
//            }
//            tableView.reloadData()
//        }
    }
}

// MARK: UITableViewDataSource
extension CategoryVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("lines: ", viewModel.trackerNameArray.count)
        return viewModel.trackerNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell")
        let usedArray = viewModel.trackerNameArray
        print("viewModel.trackerNameArray", viewModel.trackerNameArray)
        print("usedArray", usedArray)
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
