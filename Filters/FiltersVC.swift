//
//  FiitersVC.swift
//  Tracker
//
//  Created by Valery Zvonarev on 14.01.2025.
//

import UIKit

enum FilterNameEnum: String, CaseIterable {
    case allTrackers
    case todayTrackers
    case completedTrackers
    case uncompletedTrackers
    
    var filterTitle: String {
        return switch self {
        case .allTrackers: allTrackersTitle
        case .todayTrackers: todayTrackersTitle
        case .completedTrackers: completedTrackersTitle
        case .uncompletedTrackers: uncompletedTrackersTitle
        }
    }
}

final class FiltersVC: UIViewController {
    
    private var filterNames: [FilterNameEnum] = FilterNameEnum.allCases
    var selectedFilter: FilterNameEnum?
    var tappedFilter: ((FilterNameEnum) -> Void)?
    private var selectedFilterIndex: Int?
    private var tapGesture: UITapGestureRecognizer?
    
    private lazy var filterTableView: UITableView = {
        let filterTableView = UITableView(frame: .zero, style: .insetGrouped)
        filterTableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableCell")
        filterTableView.backgroundColor = .clear
        filterTableView.isScrollEnabled = false
        filterTableView.delegate = self
        filterTableView.dataSource = self
        filterTableView.separatorStyle = .singleLine
        filterTableView.separatorInset.left = 16
        filterTableView.separatorInset.right = 16
        filterTableView.layer.cornerRadius = 16
        filterTableView.layer.masksToBounds = true
        filterTableView.clipsToBounds = true
        return filterTableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = filterHeaderTitle
        viewSetup()
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    // MARK: Private functions
    private func viewSetup() {
        // page layout setup
        view.backgroundColor = TrackerColors.viewBackgroundColor
        filterTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterTableView)
        NSLayoutConstraint.activate([
            filterTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filterTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filterTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            filterTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension FiltersVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFilterIndex = indexPath.row
        selectedFilter = filterNames[indexPath.row]
        if let cell = tableView.cellForRow(at: indexPath) {
            if selectedFilterIndex == indexPath.row {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        filterTableView.reloadData()
        guard let selectedFilter else { return }
        tappedFilter?(selectedFilter)
//        dismiss(animated: true)
    }
}

extension FiltersVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FilterNameEnum.allCases.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        cell.textLabel?.text = filterNames[indexPath.row].filterTitle
        cell.selectionStyle = .none
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.backgroundColor = .ypBackground
        cell.layer.cornerRadius = 16
        selectedFilterIndex = filterNames.firstIndex(of: selectedFilter ?? .allTrackers)
        
        if selectedFilter == nil && indexPath.row == 0 {
            cell.accessoryType = .checkmark
        } else if selectedFilter != nil && selectedFilterIndex == indexPath.row {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
}


