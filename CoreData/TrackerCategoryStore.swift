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
//        print("in switchTrackerCategory: ", categoryField)
        let myRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "title == %@", categoryField)
        do {
            let res = try context.fetch(myRequest)
//            print(res)
            for entity in res {
                if entity.title == categoryField {
//                    print("entity.tracker", entity.tracker)
                    entity.removeFromTracker(trackerCoreData)
//                    print("entity.tracker", entity.tracker)
                    let requiredCategory = findCategoryByName(categoryName: isPinnedField)
                    guard let requiredCategory else {
                        print("error with requiredCategory in switchTrackerCategory")
                        return
                    }
//                    print(requiredCategory.title)
                    requiredCategory.addToTracker(trackerCoreData)
//                    print("requiredCategory.tracker", requiredCategory.tracker)
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
    
    func showCategoryContentByName(categoryName: String) {
        let myRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "title == %@", categoryName)
        do {
            let res = try context.fetch(myRequest)
            print("Count", res.count)
            for entity in res {
                print("Name:", entity.title)
                entity.tracker?.forEach {
                    print("Tracker ID:", ($0 as AnyObject).id as UUID?)
                    print("Tracker name:", ($0 as AnyObject).name as String?)
                }
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


// TODO: commented code to be deleted after 18 sprint
/*
 func addTrackerCategoryToCoreData(_ trackerCategory: TrackerCategory) throws {
 let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
 trackerCategoryCoreData.title = trackerCategory.title
 //        updateTrackerCategoryList(trackerCategoryCoreData) , with: trackerCategory)
 do {
 try context.save()
 } catch let error as NSError {
 print("in addTrackerCategoryToCoreData", error.localizedDescription)
 }
 }
 
 func updateTrackerCategoryList(_ trackerCategoryCoreData: TrackerCategoryCoreData) {
 //        print("finalTrackerCategory", finalTrackerCategory)
 //        guard let trackerCategory = finalTrackerCategory else {
 //            return
 //        }
 //        trackerCategoryCoreData.title = trackerCategory.title
 //        //        trackerCategoryCoreData.trackerArray = ""
 //        //        if trackerCategory.trackerArray.isEmpty {
 //        //            trackerCategoryCoreData.trackerArray = ""
 //        //        } else {
 //        print("finalTrackerCategory in updateTrackerCategoryList", finalTrackerCategory?.trackerArray)
 //        print("trackerCategory in updateTrackerCategoryList", trackerCategory.trackerArray)
 //        let stringValue = trackerUUIDArrayToString(trackerUUIDArray: trackerCategory.trackerArray)  // temp
 //        print("UUID string", stringValue)                                                                          // temp
 //        trackerCategoryCoreData.trackerArray = trackerUUIDArrayToString(trackerUUIDArray: trackerCategory.trackerArray)
 //        //        }
 }
 
 func addTrackerCategoryTitleToCoreData(_ trackerCategoryName: String) throws {
 let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
 trackerCategoryCoreData.title = trackerCategoryName
 //        trackerCategoryCoreData.trackerArray = ""
 //        updateTrackerCategoryList(trackerCategoryCoreData, with: trackerCategoryName)
 do {
 try context.save()
 } catch let error as NSError {
 print("in addTrackerCategoryToCoreData", error.localizedDescription, error.localizedFailureReason, error.code)
 }
 }
 
 
 func addTrackerInTrackerCategoryToCoreData(categoryName: String, trackerID: UUID) {
 print("--1--")
 //        retrieveTrackerCategoryByName(title: categoryName)
 //        guard var finalTrackerCategory = finalTrackerCategory else { return }
 //        print("trackerCategory in addTrackerInTrackerCategoryToCoreData", finalTrackerCategory)
 //        finalTrackerCategory.trackerArray.append(trackerID)
 //        do {
 //            try addTrackerCategoryToCoreData(finalTrackerCategory)
 //        } catch let error as NSError {
 //            print(error.localizedDescription, error.localizedDescription, error.localizedDescription)
 //        }
 }
 
 
 
 //    func addTrackerInTrackerCategoryToCoreData_old(categoryName: String, trackerID: UUID) {
 //        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
 //        let myRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
 //        print("category name", categoryName)
 //        myRequest.predicate = NSPredicate(format: "title == %@", categoryName)
 //        do {
 //            let res = try context.fetch(myRequest)
 //            for entity in res {
 //                if entity.title == categoryName {
 //                    entity.trackerArray! = entity.trackerArray! + " " + trackerID.uuidString
 //                }
 //            }
 //            try context.save()
 //        } catch let error as NSError {
 //            print("in addTrackerToTrackerCategory", error.localizedDescription, error.code, error.localizedFailureReason)
 //        }
 //
 //
 //        ~
 //        do {
 //            let res_count = try context.count(for: myRequest)
 //            print("Number of items:", res_count)
 //            let res = try context.fetch(myRequest)
 ////            print("Result:", res)
 ////            print("Result:", res[0])
 ////            print("Result title:", res[0].title)
 //            print("Result init array:", res[0].trackerArray)
 ////            print("Result final array:", res[0].trackerArray! + " " + trackerID.uuidString)
 ////            guard let currentTrackerArray = res[0].trackerArray else { return }
 ////            trackerCategoryCoreData.trackerArray = currentTrackerArray + " " + trackerID.uuidString
 //            if res[0].trackerArray == nil {
 //                res[0].trackerArray = trackerID.uuidString
 //            } else {
 //                res[0].trackerArray = res[0].trackerArray! + " " + trackerID.uuidString
 //            }
 //
 //            print("Result final CoreData array:", res[0].trackerArray)
 //            try context.save()
 //
 ////            print("Category \(categoryName) exists?", isCategoryAlreadyExist(categoryName: categoryName))
 ////
 ////            for entity in res {
 ////                if ((entity.trackerArray?.contains(trackerId.uuidString)) != nil) {
 ////                    print("Tracker already in category")
 ////                } else {
 ////                    entity.trackerArray?.append(trackerId.uuidString)
 ////                }
 ////            }
 //        } catch let error as NSError {
 //            print("in addTrackerToTrackerCategory", error.localizedDescription)
 //        }
 
 //    }
 
 func retrieveTrackerCategoryByName(title: String) {
 print("--2--")
 let myRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
 myRequest.predicate = NSPredicate(format: "title == %@", title)
 do {
 let res = try context.fetch(myRequest)
 for entity in res {
 print(entity.title)
 print(entity.tracker)
 let trackerSet = entity.tracker
 guard let trackerSet else { return }
 print(trackerSet)
 
 
 
 //                if entity.title == title {
 //                    let currentCategoryArray = stringToTrackerUUIDArray(stringOfUUIDs: entity.trackerArray ?? "")
 //                    print("currentCategoryArray in retrieveTrackerCategoryByName \(currentCategoryArray)")
 //                    finalTrackerCategory = TrackerCategory(title: title, trackerArray: currentCategoryArray)
 //                    print("finalTrackerCategory in retrieveTrackerCategoryByName", finalTrackerCategory)
 //                    context.delete(entity)
 //                    try context.save()
 //                }
 }
 } catch let error as NSError {
 print(error.localizedDescription)
 }
 }
 
 func findTrackerCategory(trackerId: UUID) -> String {
 let searchedUUID = trackerId.uuidString //else { return ""}
 let myRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
 //        myRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
 do {
 let res = try context.fetch(myRequest)
 //            for entity in res {
 //                if ((entity.trackerArray?.contains(trackerId.uuidString)) != nil) {
 //                    guard let title = entity.title else { return "" }
 //                    return title
 //                }
 //            }
 } catch let error as NSError {
 print(error.localizedDescription)
 return ""
 }
 return ""
 }
 
 
 
 // MARK: конвертеры
 // массив UUID трекеров в строку
 func trackerUUIDArrayToString(trackerUUIDArray: [UUID?]) -> String {
 print("in trackerUUIDArrayToString")
 print(trackerUUIDArray)
 let uuidString = trackerUUIDArray.map( { uuidValue in
 guard let uuidValue = uuidValue else {
 print()
 return "No string from UUID"
 }
 print("uuidValue in trackerUUIDArrayToString", uuidValue, uuidValue.uuidString)
 return uuidValue.uuidString
 }).joined(separator: " ")
 return uuidString
 }
 
 // строка в массив UUID трекеров
 func stringToTrackerUUIDArray(stringOfUUIDs: String) -> [UUID?] {
 print("--3--")
 let stringArray = stringOfUUIDs.split(separator: " ")
 let finalUUIDArray = stringArray.map( { UUID(uuidString: String($0)) })
 return finalUUIDArray
 }
 
 func retrieveAllTrackerCategoryTitles() -> [String] {
 var allTrackerCategoryTitles = [String]()
 let myRequest : NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
 do {
 let res = try context.fetch(myRequest)
 //            print("Entities: \(res)")
 for entity in res {
 allTrackerCategoryTitles.append(entity.title ?? "")
 }
 } catch let error as NSError {
 print(error.localizedDescription)
 }
 return allTrackerCategoryTitles
 }
 
 
 // temp function
 func countEntities() {
 //        print("in countEntities")
 let myRequest : NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
 //        myRequest.predicate = NSPredicate(format: "schedule CONTAINS[c] \(String(curDayOfWeek))")
 do {
 let counter = try context.count(for: myRequest)
 print("Found tracker categories? \(counter)")
 } catch let error as NSError {
 print(error.localizedDescription)
 }
 }
 
 //    func retrieveAllTrackers() -> [TrackerCategory] {
 func retrieveAllTrackerCategories() {
 let myRequest : NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
 //        var allTrackerCategoriesFromCoreData = [TrackerCategory]()
 do {
 let res = try context.fetch(myRequest)
 print("Entities in retrieveAllTrackerCategories: \(res)")
 for entity in res {
 print("entity title and tracker array", entity.title)
 print(entity.tracker == nil, entity.tracker?.count)
 for elem in entity.tracker! {
 print("trackers:", elem)
 guard let days = (elem as? Tracker)?.schedule else {
 print("continue since error")
 continue
 }
 print("Days of week", days)
 }
 }
 
 } catch let error as NSError {
 print(error.localizedDescription)
 }
 //        return allTrackerCategoriesFromCoreData
 }
 
 
 func deleteTrackerCategory(by title: String) {
 let myRequest : NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
 myRequest.predicate = NSPredicate(format: "title == %@", "\(title)")
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
 
 // temp function
 func deleteAllTrackerCategoryCoreDataEntities() {
 let myRequest : NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
 //        myRequest.predicate = NSPredicate(format: "name == %@", "Mark")
 //        myRequest.predicate = NSPredicate()
 
 do {
 let res = try context.fetch(myRequest)
 //            print("Entities: \(res)")
 for entity in res {
 context.delete(entity)
 }
 
 try context.save()
 print("All category entities deleted, saving context, number of entities:", countEntities())
 } catch let error as NSError {
 print(error.localizedDescription)
 }
 }
 
 }
 */



