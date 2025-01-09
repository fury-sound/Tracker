//
//  File.swift
//  Tracker
//
//  Created by Valery Zvonarev on 08.12.2024.
//

import UIKit
import CoreData

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    weak var delegateTrackerForNotifications: TrackerNavigationViewProtocol?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
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
    
    func addTrackerToCoreData(_ tracker: Tracker) throws -> TrackerCoreData {
//    func addTrackerToCoreData(_ tracker: Tracker) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        updateTrackerList(trackerCoreData, with: tracker)
        do {
            try context.save()
        } catch let error as NSError {
            print("Error with adding tracker to CoreData in addTrackerToCoreData, TrackerStore:", error.localizedDescription, error.code, error.userInfo)
        }
        return trackerCoreData
    }
    
    func updateTrackerList(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emojiPic = tracker.emojiPic
        if tracker.schedule.isEmpty {
            trackerCoreData.schedule = ""
        } else {
            trackerCoreData.schedule = scheduleToString(schedule: tracker.schedule)
        }
        trackerCoreData.color = tracker.color
    }
    
    func addEventToCoreData(_ event: Tracker) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        updateEventList(trackerCoreData, with: event)
        do {
            try context.save()
        } catch let error as NSError {
            print("Error with adding tracker to CoreData in addEventToCoreData, TrackerStore:", error.localizedDescription)
        }
    }
    
    func updateEventList(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emojiPic = tracker.emojiPic
        trackerCoreData.schedule = ""
        trackerCoreData.color = tracker.color
    }
    
    // temp function - to be deleted at the end
    func retrieveAllTrackers() -> [Tracker] {
        let myRequest : NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        var allTrackerFromCoreData = [Tracker]()
        do {
            let res = try context.fetch(myRequest)
            //            print("Entities: \(res)")
            for entity in res {
                //                print(entity.id, entity.name, entity.emojiPic, entity.color)
                if entity.schedule == "" {
                    let arr: [ScheduledDays] = []
                    allTrackerFromCoreData.append(Tracker(id: entity.id, name: entity.name, emojiPic: entity.emojiPic, color: entity.color as? UIColor, schedule: arr))
                } else {
                    allTrackerFromCoreData.append(Tracker(id: entity.id, name: entity.name, emojiPic: entity.emojiPic, color: entity.color as? UIColor, schedule: stringToSchedule(scheduleString: entity.schedule ?? "")))
                }
//                print("Tracker \(entity.name) category :", entity.category?.title)
            }
        } catch let error as NSError {
            print("Error retrieving trackers in retrieveAllTrackers(), TrackerStore", error.localizedDescription)
        }
        return allTrackerFromCoreData
    }
    
    func retrieveTracker(by id: UUID) -> Tracker? {
        var trackerToFind: Tracker?
        let myRequest : NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "id == %@", "\(id)")
        
        do {
            let res = try context.fetch(myRequest)
            for entity in res {
                if entity.schedule == "" {
                    let arr: [ScheduledDays] = []
                    trackerToFind = Tracker(id: entity.id, name: entity.name, emojiPic: entity.emojiPic, color: entity.color as? UIColor, schedule: arr)
                } else {
                    trackerToFind = Tracker(id: entity.id, name: entity.name, emojiPic: entity.emojiPic, color: entity.color as? UIColor, schedule: stringToSchedule(scheduleString: entity.schedule ?? ""))
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return trackerToFind
    }
    
//    func filterTrackersByWeekday(dayOfWeek: Int) -> [Tracker]? {
    func filterTrackersByWeekday(dayOfWeek: Int) -> [String: [Tracker]]? {
        var arrayForTrackers = [Tracker]()
        var dictionaryForTrackerCategory: [String: [Tracker]] = [:]
        let arr: [ScheduledDays] = []
        let myRequest : NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "schedule CONTAINS[c] %@ OR schedule == %@", String(dayOfWeek), "")
        do {
            let res = try context.fetch(myRequest)
            for entity in res {
                guard let categoryTitle = entity.category?.title else { return nil }
                if dictionaryForTrackerCategory[categoryTitle] == nil {
                    dictionaryForTrackerCategory[categoryTitle] = []
                }
//                dictionaryForTrackerCategory[categoryTitle]?.append(entity)
                if entity.schedule == "" {
                    arrayForTrackers.append(Tracker(id: entity.id, name: entity.name, emojiPic: entity.emojiPic, color: entity.color as? UIColor, schedule: arr))
                    dictionaryForTrackerCategory[categoryTitle]?.append(Tracker(id: entity.id, name: entity.name, emojiPic: entity.emojiPic, color: entity.color as? UIColor, schedule: arr))
                } else {
                    arrayForTrackers.append(Tracker(id: entity.id, name: entity.name, emojiPic: entity.emojiPic, color: entity.color as? UIColor, schedule: stringToSchedule(scheduleString: entity.schedule ?? "")))
                    dictionaryForTrackerCategory[categoryTitle]?.append(Tracker(id: entity.id, name: entity.name, emojiPic: entity.emojiPic, color: entity.color as? UIColor, schedule: stringToSchedule(scheduleString: entity.schedule ?? "")))
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
//        print("dictionaryForTrackerCategory", dictionaryForTrackerCategory)
//        return arrayForTrackers
        return dictionaryForTrackerCategory
    }
    
    func filterTrackersByWeekdayForTrackerCoreData(dayOfWeek: Int, trackerCoreData: TrackerCoreData) -> [Tracker] {
        var arrayForTrackers = [Tracker]()
        let arr: [ScheduledDays] = []
//        let currentTrackerCoreData = trackerCoreData
        let myRequest : NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "schedule CONTAINS[c] %@ OR schedule == %@", String(dayOfWeek), "")
        do {
            let res = try context.fetch(myRequest)
            for entity in res {
                if entity.schedule == "" {
                    arrayForTrackers.append(Tracker(id: entity.id, name: entity.name, emojiPic: entity.emojiPic, color: entity.color as? UIColor, schedule: arr))
                } else {
                    arrayForTrackers.append(Tracker(id: entity.id, name: entity.name, emojiPic: entity.emojiPic, color: entity.color as? UIColor, schedule: stringToSchedule(scheduleString: entity.schedule ?? "")))
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return arrayForTrackers
    }
    
    // temp function
    func countEntities(curDayOfWeek: Int) {
//        print("in countEntities")
        let myRequest : NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
//        myRequest.predicate = NSPredicate(format: "schedule CONTAINS[c] \(String(curDayOfWeek))")
        do {
            let counter = try context.count(for: myRequest)
//            print("Found records? \(counter)")
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func countAllEntities() {
//        print("in countEntities")
        let myRequest : NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
//        myRequest.predicate = NSPredicate(format: "schedule CONTAINS[c] \(String(curDayOfWeek))")
        do {
            let counter = try context.count(for: myRequest)
            print("In countAllEntities, TrackerStore: found tracker records? \(counter)")
//            print("in countAllEntities, TrackerStore:", retrieveAllTrackers())
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func deleteTracker(by id: UUID) {
        let myRequest : NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "id == %@", "\(id)")
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
    
    // temo function
    func deleteAllTrackerCoreDataEntities() {
        let myRequest : NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
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
    
    func scheduleToString(schedule: [ScheduledDays]) -> String {
        let weekString = schedule.map( { String($0.rawValue) }).joined(separator: " ")
        return weekString
    }
    
    func stringToSchedule(scheduleString: String) -> [ScheduledDays] {
        let scheduledDaysArray = scheduleString.compactMap { elemDay in
            return switch elemDay {
            case "1": ScheduledDays.Mon
            case "2": ScheduledDays.Tue
            case "3": ScheduledDays.Wed
            case "4": ScheduledDays.Thu
            case "5": ScheduledDays.Fri
            case "6": ScheduledDays.Sat
            case "0": ScheduledDays.Sun
            default: nil
            }
        }
        return scheduledDaysArray
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        guard let delegateTrackerForNotifications else {
            return
        }
        delegateTrackerForNotifications.addingTrackerOnScreen()
    }
}

// temp storage - if I need those functions later. 
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
//        print("in controllerWillChangeContent")
//        let objects = controller.fetchedObjects
//        print(objects?.count)
//        let objects = controller.fetchedObjects
//        var insertedIndexes = IndexSet()
//        print(objects)
//    }
    
    
//    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
//            print("in insert")
//            let objects = controller.fetchedObjects
//            print(objects?.count)
//            guard let objects else {return}
//            for elem in objects {
//                print(elem)
//            }
//        case .delete:
//            print("in delete")
//        default:
//            print("default")
//            break
//        }
//    }

