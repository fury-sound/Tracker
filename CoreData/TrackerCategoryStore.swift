//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Valery Zvonarev on 08.12.2024.
//

//import Foundation
import UIKit
import CoreData

final class TrackerCategoryStore: NSObject {
    
    private let context: NSManagedObjectContext
    weak var delegateTrackerCategoryForNotifications: TrackerNavigationViewProtocol?

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchedResultsController.delegate = self
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
    
    // test method to be deleted
    func addTrackerCategoryTitleToCoreData(_ trackerCategoryTitle: String) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.title = trackerCategoryTitle
        //        updateTrackerCategoryList(trackerCategoryCoreData) , with: trackerCategory)
        do {
            try context.save()
        } catch let error as NSError {
            print("Failed to fetch tracker category titles in addTrackerCategoryTitleToCoreData:", error.localizedDescription)
        }
    }
        
    func addTrackerToCategory(_ trackerCategoryCoreData: TrackerCategoryCoreData, trackerCoreData: TrackerCoreData) throws {
        trackerCategoryCoreData.addToTracker(trackerCoreData)
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func switchTrackerCategory(trackerCoreData: TrackerCoreData, categoryField: String, isPinnedField: String) {
        let myRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "title == %@", categoryField)
        do {
            let res = try context.fetch(myRequest)
            for entity in res {
                if entity.title == categoryField {
                    entity.removeFromTracker(trackerCoreData)
                    let requiredCategory = findCategoryByName(categoryName: isPinnedField)
                    guard let requiredCategory else {
                        print("error with requiredCategory in switchTrackerCategory")
                        return
                    }
                    requiredCategory.addToTracker(trackerCoreData)
                }
            }
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    func changeTrackerCategory(trackerCoreData: TrackerCoreData, startCategory: String, targetCategory: String) {
        let myRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "title == %@", startCategory)
        do {
            let res = try context.fetch(myRequest)
            for entity in res {
                if entity.title == startCategory {
                    entity.removeFromTracker(trackerCoreData)
                    let targetCategoryInCoreData = findCategoryByName(categoryName: targetCategory)
                    guard let targetCategoryInCoreData else {
                        print("error with targetCategoryInCoreData in changeTrackerCategory")
                        return
                    }
                    targetCategoryInCoreData.addToTracker(trackerCoreData)
                }
            }
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    func changeTrackerCategoryName(startCategory: String, targetCategory: String) {
        let myRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "title == %@", startCategory)
        do {
            let res = try context.fetch(myRequest)
            for entity in res {
                if entity.title == startCategory {
                    entity.title = targetCategory
                }
            }
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    func deleteTrackerCategoryName(categoryName: String) {
        let myRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "title == %@", categoryName)
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
    
    func retrieveTrackerForCategoryByName(categoryName: String) -> [UUID]? {
        var trackersForCategory: [UUID] = []
        let myRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "title == %@", categoryName)
        do {
            let res = try context.fetch(myRequest)
            for entity in res {
                entity.tracker?.allObjects.forEach { (tracker) in
                    if let tracker = tracker as? TrackerCoreData {
                        trackersForCategory.append(tracker.id!)
                    }
                }
            }
            return trackersForCategory
        } catch let error as NSError {
            print("Error, retrieveTrackerForCategoryByName in TrackerCategoryStore", error.localizedDescription, error.userInfo)
            return nil
        }
    }
    
    func retrieveTrackerForCategoryByNameForPinned(categoryName: String) -> [UUID]? {
        var trackersForCategory: [UUID] = []
        let myRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "title == %@", "Pinned")
        do {
            let res = try context.fetch(myRequest)
            for entity in res {
                entity.tracker?.allObjects.forEach { (tracker) in
                    if let tracker = tracker as? TrackerCoreData {
                        if tracker.isPinned == categoryName {
                            trackersForCategory.append(tracker.id!)
                        }
                    }
                }
            }
            return trackersForCategory
        } catch let error as NSError {
            print("Error, retrieveTrackerForCategoryByName in TrackerCategoryStore", error.localizedDescription, error.userInfo)
            return nil
        }
    }
    
    func findCategoryByName(categoryName: String) -> TrackerCategoryCoreData? {
        let myRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "title == %@", categoryName)
        do {
            let res = try context.fetch(myRequest)
            return res.first
        } catch let error as NSError {
            print("Error with finding suitable tracker category, findCategoryByName in TrackerCategoryStore", error.localizedDescription, error.userInfo)
            return nil
        }
    }
    // to be deleted
    func showCategoryContentByName(categoryName: String) {
        let myRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "title == %@", categoryName)
        do {
            let res = try context.fetch(myRequest)
//            print("Count", res.count)
            for entity in res {
//                print("Name:", entity.title)
//                entity.tracker?.forEach {
//                    print("Tracker ID:", ($0 as AnyObject).id as UUID?)
//                    print("Tracker name:", ($0 as AnyObject).name as String?)
//                }
            }
        } catch let error as NSError {
            print("Error with finding suitable tracker category, findCategoryByName in TrackerCategoryStore", error.localizedDescription, error.userInfo)
            return
        }
    }
    
    func isCategoryAlreadyExist(categoryName: String) -> Bool {
        let myRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "title == %@", categoryName)
        do {
            let res = try context.fetch(myRequest)
            for entity in res {
                if entity.title == categoryName {
                    return true
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return false
        }
        return false
    }
    
    
    // Category tracker search and filtering for suitable trackers - temp function to be deleted, no callers
    func findCategoryWithSuitableTrackers(dayOfWeek: Int) -> [TrackerCategory]? {
        let myRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        do {
            let res = try context.fetch(myRequest)
            for entity in res {
                entity.tracker?.forEach {
                    let trackerUUID = ($0 as AnyObject).id as UUID?
                    let trackerSchedule = ($0 as AnyObject).schedule as String?
                }
            }
        } catch let error as NSError {
            print("Error with finding suitable tracker category, findCategoryWithSuitableTrackers in TrackerCategoryStore", error.localizedDescription)
        }
        return nil
    }
        
    func retrieveAllTrackerCategoryTitles() -> [String] {
        var allTrackerCategoryTitles = [String]()
        let myRequest : NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        do {
            let res = try context.fetch(myRequest)
            if res.count == 0 {
                return allTrackerCategoryTitles
            }
            for entity in res {
                allTrackerCategoryTitles.append(entity.title ?? "empty category")
            }
        } catch let error as NSError {
            print("Error in retrieveAllTrackerCategoryTitles:", error.localizedDescription)
        }
        return allTrackerCategoryTitles
    }
 
    // temp function to be deleted
        func retrieveCategoryTitles() {
            let myRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
            do {
                let res = try context.fetch(myRequest)
                for entity in res {
                    print("Tracker category title:", entity.title)
                }
            } catch let error as NSError {
                print("Error with finding suitable tracker category, findCategoryWithSuitableTrackers in TrackerCategoryStore", error.localizedDescription)
            }
        }
    
    // temp function to be deleted
    func deleteAllTrackerCategoryCoreDataEntities() {
        let myRequest : NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        do {
            let res = try context.fetch(myRequest)
            //            print("Entities: \(res)")
            for entity in res {
                context.delete(entity)
            }
            try context.save()
//            print("All category entities deleted, saving context")
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func countEntities() {
        let myRequest : NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        //        myRequest.predicate = NSPredicate(format: "schedule CONTAINS[c] \(String(curDayOfWeek))")
        do {
            let counter = try context.count(for: myRequest)
//            print("Found tracker categories? \(counter)")
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        //        print("in controllerWillChangeContent for TrackerRecordStore")
        //        let objects = controller.fetchedObjects
        //        print(objects?.count)
        //        let objects = controller.fetchedObjects
        //        var insertedIndexes = IndexSet()
        //        print(objects)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        //        guard let currentCell, let trackerId else {return}
        //        let counter = countEntities(id: trackerId)
        //        currentCell.setDayLabelText(days: counter)
        
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        //        guard let currentCell else {return}
        //        switch type {
        //        case .insert:
        //            currentCell.setButtonSign(isPlusSignOnFlag: true)
        //        case .delete:
        //            currentCell.setButtonSign(isPlusSignOnFlag: false)
        //        default:
        //            break
        //        }
    }
}
