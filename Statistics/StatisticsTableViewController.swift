//
//  StatisticsTableViewController.swift
//  Tracker
//
//  Created by Valery Zvonarev on 03.11.2024.
//

import UIKit
import CoreData

//protocol TrackerRecordStoreDelegate: AnyObject {
//    func sendingStatisticsData(_ completedTrackers: Int)
//    func didUpdateRecords(_ records: [TrackerRecordCoreData])
//    //    func controllerDidUpdateFetchedResults(_ controller: NSFetchedResultsController<TrackerRecordCoreData>)
//}

//protocol CounterProtocol: AnyObject {
//    func didUpdateCount(_ count: Int)
//}

//final class StatisticsTableViewController: UIViewController, TrackerRecordStoreDelegate  {
final class StatisticsTableViewController: UIViewController  {

    //    func didUpdateCount(_ count: Int) {
    //        print("Count updated to: \(count)")
    //    }
    
    //    func controllerDidUpdateFetchedResults(_ controller: NSFetchedResultsController<TrackerRecordCoreData>) {
    //        let fetchedObjects = controller.fetchedObjects
    //        print("fetchedObjects?.count in controllerDidUpdateFetchedResults:", fetchedObjects?.count)
    //    }
    
    private lazy var nothingFoundImageView: UIImageView = {
        let image = UIImage.noData
        let nothingFoundImageView = UIImageView(image: image)
        nothingFoundImageView.backgroundColor = TrackerColors.viewBackgroundColor
        return nothingFoundImageView
    }()
    
    private lazy var nothingFoundLogo: UILabel = {
        let nothingFoundLogo = UILabel()
        nothingFoundLogo.backgroundColor = TrackerColors.viewBackgroundColor
        nothingFoundLogo.text = nothingToAnalyzeText
        nothingFoundLogo.font = .systemFont(ofSize: 12, weight: .medium)
        nothingFoundLogo.textColor = TrackerColors.backgroundButtonColor
        nothingFoundLogo.sizeToFit()
        return nothingFoundLogo
    }()
    
    private lazy var titleLabel: UILabel = {
        let nothingFoundLogo = UILabel()
        nothingFoundLogo.backgroundColor = TrackerColors.viewBackgroundColor
        nothingFoundLogo.text = statisticsTitle
        nothingFoundLogo.textAlignment = .natural
        nothingFoundLogo.font = .systemFont(ofSize: 34, weight: .bold)
        nothingFoundLogo.textColor = TrackerColors.backgroundButtonColor
        nothingFoundLogo.sizeToFit()
        return nothingFoundLogo
    }()
    
    private lazy var statisticsItemLabelTop: UILabel = {
        let statisticsItemLabelTop = UILabel()
        statisticsItemLabelTop.backgroundColor = TrackerColors.viewBackgroundColor
        statisticsItemLabelTop.text = ""
        statisticsItemLabelTop.font = .systemFont(ofSize: 34, weight: .bold)
        statisticsItemLabelTop.textAlignment = .natural
        statisticsItemLabelTop.textColor = TrackerColors.backgroundButtonColor
        statisticsItemLabelTop.isHidden = true
        statisticsItemLabelTop.sizeToFit()
        return statisticsItemLabelTop
    }()
    
    private lazy var statisticsItemLabelBottom: UILabel = {
        let statisticsItemLabelBottom = UILabel()
        statisticsItemLabelBottom.backgroundColor = TrackerColors.viewBackgroundColor
//        statisticsItemLabelBottom.backgroundColor = .clear
        statisticsItemLabelBottom.text = ""
        statisticsItemLabelBottom.font = .systemFont(ofSize: 12, weight: .medium)
        statisticsItemLabelBottom.textAlignment = .natural
        statisticsItemLabelBottom.textColor = TrackerColors.backgroundButtonColor
        statisticsItemLabelBottom.isHidden = true
        statisticsItemLabelBottom.sizeToFit()
        return statisticsItemLabelBottom
    }()
    
    private lazy var stackView = {
        let stackView = UIStackView(arrangedSubviews: [statisticsItemLabelTop, statisticsItemLabelBottom])
        stackView.backgroundColor = .clear
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
//        stackView.layer.borderWidth = 1
        stackView.isLayoutMarginsRelativeArrangement = true
        let insets = UIEdgeInsets(top: 15, left: 12, bottom: 12, right: 12)
        stackView.layoutMargins = insets
        stackView.spacing = 7
        stackView.layer.cornerRadius = 8
        stackView.isHidden = true
        return stackView
    }()
    
    private lazy var gradientBorderView = {
        let gradientBorderView = GradientBorderView(
            frame: .zero,
            cornerRadius: 16,
            borderWidth: 1,
            colors: [.ypTartOrange, .ypEucalyptus, .ypAzure]
        )
        gradientBorderView.backgroundColor = .clear
        return gradientBorderView
    }()
        
    private var completedTrackersVariable: Int = 0 {
        didSet {
//            print("in didSet")
            if completedTrackersVariable != 0 {
//                print("in completedTrackers != 0")
                statisticsItemLabelTop.text = "\(completedTrackersVariable)"
                statisticsItemLabelBottom.text = completedTrackersText
                statisticsItemLabelTop.isHidden = false
                statisticsItemLabelBottom.isHidden = false
                stackView.isHidden = false
                gradientBorderView.isHidden = false
            } else {
//                print("in completedTrackers == 0")
                statisticsItemLabelTop.isHidden = true
                statisticsItemLabelBottom.isHidden = true
                gradientBorderView.isHidden = true
                stackView.isHidden = true
            }
            imagesToShowOnEmptyScreen()
        }
    }
    
    //    init(context: NSManagedObjectContext) {
    //        trackerRecordStore = TrackerRecordStore(context: context)
    //        trackerRecordStore?.delegate = self
    //        super.init()
    //    }
    //
    //    required init?(coder: NSCoder) {
    //        fatalError("init(coder:) has not been implemented")
    //    }
    
//    var trackerRecordStore: TrackerRecordStore?
//    var context: NSManagedObjectContext?
    
    let trackerRecordStore = TrackerRecordStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TrackerColors.viewBackgroundColor
//        trackerRecordStore.de?legate = self
//        trackerRecordStore.setTrackerRecordForStatistics(statisticsVC: self)
//        trackerRecordStore.setupFRC()

//        self.context = trackerRecordStore?.context
//        print("context.name in viewDidLoad:", context?.name)
        
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//    }
//        trackerRecordStore.setupFRC()
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //        trackerRecordStore.delegate = self
        //        trackerRecordStore.recordsCounter()
//        trackerRecordStore.setupFRC()
        //        trackerRecordStore.notifyDelegate()
        
        //        trackerRecordStore?.setStatisticsInstance(statistics: self)
        //        trackerRecordStore?.setupFRC()
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        completedTrackersVariable = trackerRecordStore.countEntitiesForStatistics() ?? 0
    }
    
//    func didUpdateRecords(_ records: [TrackerRecordCoreData]) {
//        print("Updated records received: \(records)")
//    }
//    
//    func sendingStatisticsData(_ completedTrackers: Int) {
//        print("completedTrackers", completedTrackers)
//        self.completedTrackersVariable = completedTrackers
//    }
    
    private func setupView() {
        completedTrackersVariable = trackerRecordStore.countEntitiesForStatistics() ?? 0
//        print("completedTrackers in setupView, StatisticsTableViewController:", completedTrackersVariable)
//        gradientBorderView.translatesAutoresizingMaskIntoConstraints = false
//        gradientBorderView.addSubview(stackView)
        let objectsToShow = [titleLabel, gradientBorderView, stackView, nothingFoundImageView, nothingFoundLogo]
        objectsToShow.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleLabel.heightAnchor.constraint(equalToConstant: 41),
            nothingFoundImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nothingFoundImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            nothingFoundImageView.heightAnchor.constraint(equalToConstant: 80),
            nothingFoundImageView.widthAnchor.constraint(equalToConstant: 80),
            nothingFoundLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nothingFoundLogo.topAnchor.constraint(equalTo: nothingFoundImageView.bottomAnchor, constant: 8),
            
            stackView.topAnchor.constraint(equalTo: gradientBorderView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: gradientBorderView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: gradientBorderView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: gradientBorderView.bottomAnchor),
            
            gradientBorderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            gradientBorderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            gradientBorderView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 60),
            //            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            gradientBorderView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func imagesToShowOnEmptyScreen() {
        if completedTrackersVariable == 0 {
            nothingFoundImageView.isHidden = false
            nothingFoundLogo.isHidden = false
        } else {
            nothingFoundImageView.isHidden = true
            nothingFoundLogo.isHidden = true
            
        }
    }
}
