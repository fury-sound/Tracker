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
//    private let trackerDate: String?
    private var currentCell: TrackerCellViewController?
    private var trackerId: UUID?
    

    //    private let uiColorMarshalling = UIColorMarshalling()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "id", ascending: true)
        ]
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchedResultsController.delegate = self
//        do {
//            try fetchedResultsController.performFetch()
//        } catch let error as NSError {
//            print("Failed to fetch entities: \(error.localizedDescription)")
//        }
        return fetchedResultsController
    }()
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
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
//        trackerCoreData.name = tracker.name
//        trackerCoreData.emojiPic = tracker.emojiPic
//        //        trackerCoreData.schedule = tracker.schedule
//        trackerCoreData.schedule = scheduleToString(schedule: tracker.schedule)
//        trackerCoreData.color = tracker.color
        //        trackerCoreData.colorHex = uiColorMarshalling.hexString(from: mix.backgroundColor)
    }
    
    func checkDateForCompletedTrackersInCoreData(trackerRecord: TrackerRecord) -> Bool {
//        let res = completedTrackers.contains { $0.dateExecuted == tracker.dateExecuted && $0.id == tracker.id }
        
        let myRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "(dateExecuted == %@) AND (id == %@)", trackerRecord.dateExecuted, trackerRecord.id as CVarArg)
        do {
            let res = try context.fetch(myRequest)
//            print(res)
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
    
    func isTrackerIdInTrackerRecords(trackerRecord: TrackerRecord) -> Bool {
        
        let myRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "id == %@", trackerRecord.id as CVarArg)
        do {
            let res = try context.fetch(myRequest)
//            print(res)
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
    
    func deleteTrackerRecord(by id: UUID, date: String) {
        let myRequest : NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "(dateExecuted == %@) AND (id == %@)", date, id as CVarArg)
        do {
            let res = try context.fetch(myRequest)
//            print("Entities: \(res)")
            for entity in res {
//                print(entity)
//                print(entity.id)
//                print(entity.dateExecuted)
                context.delete(entity)
            }
            try context.save()
            //            print("Saving context without the deleted entity")
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func countEntities(id: UUID) -> Int {
//        print("in countEntities")
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
    
    // MARK: temp functions
    func countEntities() {
//        print("in countEntities")
        let myRequest : NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
//        myRequest.predicate = NSPredicate(format: "schedule CONTAINS[c] \(String(curDayOfWeek))")
        do {
            let counter = try context.count(for: myRequest)
//            print("Found trackerRecords? \(counter)")
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func deleteAllTrackerRecordCoreDataEntities() {
        let myRequest : NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        //        myRequest.predicate = NSPredicate(format: "name == %@", "Mark")
        //        myRequest.predicate = NSPredicate()
        
        do {
            let res = try context.fetch(myRequest)
//            print("Entities: \(res)")
            for entity in res {
                context.delete(entity)
            }
            try context.save()
            //            print("All entities deleted, saving context")
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
//        print("in controllerWillChangeContent for TrackerRecordStore")
//        let objects = controller.fetchedObjects
//        print(objects?.count)
//        let objects = controller.fetchedObjects
//        var insertedIndexes = IndexSet()
//        print(objects)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
//        print("In controllerDidChangeContent for TrackerRecordStore - Updated CoreData")
//        let objects = controller.fetchedObjects
//        print(objects?.count)
        guard let currentCell, let trackerId else {return}
        let counter = countEntities(id: trackerId)
        currentCell.setDayLabelText(days: counter)
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let currentCell else {return}
        switch type {
        case .insert:
//            print("in insert")
            currentCell.setButtonSign(isPlusSignOnFlag: true)
        case .delete:
//            print("in delete")
            currentCell.setButtonSign(isPlusSignOnFlag: false)
        default:
//            print("default")
            break
        }
    }
    
}

