//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Valery Zvonarev on 08.12.2024.
//

import UIKit
import CoreData

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    weak var delegateTrackerRecordForNotifications: TrackerNavigationViewProtocol?
    
//    weak var delegate: TrackerRecordStoreDelegate?
//    private var statisticsViewController: StatisticsTableViewController?
    
    private var currentCell: TrackerCellViewController?
//    private var statisticsVC: StatisticsTableViewController?
    private var trackerId: UUID?
        
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "id", ascending: true)
        ]
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
        
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext, statisticsVC: StatisticsTableViewController) {
        self.context = context
//        self.statisticsVC = statisticsVC
        super.init()
        setupFRC()
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFRC()
    }
    
    func setupFRC() {
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Failed to fetch entities: \(error.localizedDescription)")
        }
    }
    
    func setTrackerRecordParams(trackerId: UUID, currentCell: TrackerCellViewController) {
        self.currentCell = currentCell
        self.trackerId = trackerId
    }
    
    func addTrackerRecordToCoreData(_ trackerRecord: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        updateTrackerRecordList(trackerRecordCoreData, with: trackerRecord)
        do {
            try context.save()
        } catch let error as NSError {
            print("in addTrackerRecordToCoreData", error.localizedDescription)
        }
    }
    
    func updateTrackerRecordList(_ trackerRecordCoreData: TrackerRecordCoreData, with trackerRecord: TrackerRecord) {
        trackerRecordCoreData.id = trackerRecord.id
        trackerRecordCoreData.dateExecuted = trackerRecord.dateExecuted
    }
    
    func checkDateForCompletedTrackersInCoreData(trackerRecord: TrackerRecord) -> Bool {
        
        let myRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "(dateExecuted == %@) AND (id == %@)", trackerRecord.dateExecuted, trackerRecord.id as CVarArg)
        do {
            let res = try context.fetch(myRequest)
            return res.isEmpty ? false : true
        } catch let error as NSError {
            print(error.localizedDescription)
            return false
        }
    }
    
    func checkDateForUncompletedTrackersInCoreData(trackerRecord: TrackerRecord) -> Bool {
        let myRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "(dateExecuted != %@) AND (id == %@)", trackerRecord.dateExecuted, trackerRecord.id as CVarArg)
        do {
            let res = try context.fetch(myRequest)
            return res.isEmpty ? false : true
        } catch let error as NSError {
            print(error.localizedDescription)
            return false
        }
    }
    
    func isTrackerIdInTrackerRecords(trackerRecord: TrackerRecord) -> Bool {
        
        let myRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "id == %@", trackerRecord.id as CVarArg)
        do {
            let res = try context.fetch(myRequest)
            if res.isEmpty {
                return false
            } else {
                return true
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return false
        }
    }
    
    func deleteTrackerRecordByID(by id: UUID) {
        let myRequest : NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            let res = try context.fetch(myRequest)
            for entity in res {
                context.delete(entity)
            }
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func deleteTrackerRecord(by id: UUID, date: String) {
        let myRequest : NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "(dateExecuted == %@) AND (id == %@)", date, id as CVarArg)
        do {
            let res = try context.fetch(myRequest)
            for entity in res {
                context.delete(entity)
            }
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    // MARK: temp functions
    func countEntities(id: UUID) -> Int {
        var counter = 0
        let myRequest : NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            counter = try context.count(for: myRequest)
//            print("Found trackerRecords? \(counter)")
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return counter
    }
    
    func countEntitiesForStatistics() -> Int? {
        let myRequest : NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        var completedTrackerCount = 0
        do {
            let res = try context.fetch(myRequest)
            for entity in res {
                if entity.dateExecuted != nil {
                    completedTrackerCount += 1
                }
            }
            return completedTrackerCount
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return 0
    }
    
    func countEntities() {
        let myRequest : NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        do {
            let counter = try context.count(for: myRequest)
//            print("Found trackerRecords? \(counter)")
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func retrieveAllTrackerRecordCoreDataInfo() {
        let myRequest : NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        print("All entities in TrackerRecordCoreData:")
        do {
            let res = try context.fetch(myRequest)
            for (index, entity) in res.enumerated() {
//                print("\(index) Entity: \(entity)")
//                print("\(index) Entity name: \(entity.id)")
//                print("\(index) Entity date: \(entity.dateExecuted)")
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func deleteAllTrackerRecordCoreDataEntities() {
        let myRequest : NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        do {
            let res = try context.fetch(myRequest)
//            print("Entities: \(res)")
            for entity in res {
                context.delete(entity)
            }
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    // MARK: end of temp functions
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
//        print("willChangeContent - in controllerWillChangeContent for TrackerRecordStore")
//        retrieveAllTrackerRecordCoreDataInfo()
//        let objects = controller.fetchedObjects
//        print(objects?.count)
//        let objects = controller.fetchedObjects
//        var insertedIndexes = IndexSet()
//        print(objects)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        guard let currentCell, let trackerId else {return}
        let counter = countEntities(id: trackerId)
        currentCell.setDayLabelText(days: counter)
        
//        ### for delegate pattern - not working
//        print("context.name in didChangeContent:", context.name)
////        notifyDelegate()
//        
//        if let records = controller.fetchedObjects as? [TrackerRecordCoreData] {
//            delegate?.didUpdateRecords(records)
//        }
//        
//        guard let delegate else {
//            print("no delegateTrackerStatisticsNotifications")
//            return
//        }
//        
//        var completedTrackers = countEntitiesForStatistics()
//        delegate.sendingStatisticsData(completedTrackers ?? 0)
//        print("Number changed, completedTrackers: \(completedTrackers)")
//        retrieveAllTrackerRecordCoreDataInfo()
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let currentCell else {return}
        switch type {
        case .insert:
            currentCell.setButtonSign(isPlusSignOnFlag: true)
        case .delete:
            currentCell.setButtonSign(isPlusSignOnFlag: false)
        default:
            break
        }
    }
}

