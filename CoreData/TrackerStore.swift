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

    //    private let uiColorMarshalling = UIColorMarshalling()
    
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
    
    func addTrackerToCoreData(_ tracker: Tracker) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        updateTrackerList(trackerCoreData, with: tracker)
        do {
            try context.save()
        } catch let error as NSError {
            print("in addTrackerToCoreData", error.localizedDescription)
        }
    }
    
    func updateTrackerList(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emojiPic = tracker.emojiPic
        //        trackerCoreData.schedule = tracker.schedule
//        print("tracker.schedule", tracker.schedule)
        if tracker.schedule.isEmpty {
            trackerCoreData.schedule = ""
        } else {
            trackerCoreData.schedule = scheduleToString(schedule: tracker.schedule)
        }
        trackerCoreData.color = tracker.color
        //        trackerCoreData.colorHex = uiColorMarshalling.hexString(from: mix.backgroundColor)
    }
    
    func addEventToCoreData(_ event: Tracker) throws {
//        print("in addTrackerToCoreData")
        let trackerCoreData = TrackerCoreData(context: context)
        updateEventList(trackerCoreData, with: event)
        do {
            try context.save()
        } catch let error as NSError {
            print("in addTrackerToCoreData", error.localizedDescription)
        }
//        print(trackerCoreData)
    }
    
    func updateEventList(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
//        print("in updateEventList")
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emojiPic = tracker.emojiPic
        trackerCoreData.schedule = ""
        trackerCoreData.color = tracker.color
    }
    
    // temp function
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
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return allTrackerFromCoreData
    }
    
    func retrieveTracker(by id: UUID) -> Tracker? {
        var trackerToFind: Tracker?
        let myRequest : NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "id == %@", "\(id)")
        
        do {
            let res = try context.fetch(myRequest)
//            print("Entities: \(res)")
            for entity in res {
                //                guard let schedule = entity.schedule else { return trackerNext }
                //                print(entity.id, entity.name, entity.emojiPic, entity.color)
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
    
    func filterTrackersByWeekday(dayOfWeek: Int) -> [Tracker] {
//        print("in filterTrackersByWeekday")
        var arrayForTrackers = [Tracker]()
        let arr: [ScheduledDays] = []

//        let trackerRecord = TrackerRecord()
        let myRequest : NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
//        print(dayOfWeek, "\(String(dayOfWeek))")
//        print(myRequest)
//        let dayOfWeekString = String(dayOfWeek)
//        myRequest.predicate = NSPredicate(format: "schedule CONTAINS[c] %@", String(dayOfWeek))
        myRequest.predicate = NSPredicate(format: "schedule CONTAINS[c] %@ OR schedule == %@", String(dayOfWeek), "")
        do {
            let res = try context.fetch(myRequest)
//            print("fetch result", res)
            for entity in res {
//                let arr: [ScheduledDays] = []
//                print("schedule", entity.schedule)
                if entity.schedule == "" {
                    arrayForTrackers.append(Tracker(id: entity.id, name: entity.name, emojiPic: entity.emojiPic, color: entity.color as? UIColor, schedule: arr))
                } else {
                    arrayForTrackers.append(Tracker(id: entity.id, name: entity.name, emojiPic: entity.emojiPic, color: entity.color as? UIColor, schedule: stringToSchedule(scheduleString: entity.schedule ?? "")))
                }
            }
//            print("Found records? \(arrayForTrackers.count)")
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
    
    func deleteTracker(by id: UUID) {
        let myRequest : NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "id == %@", "\(id)")
        do {
            let res = try context.fetch(myRequest)
            //            print("Entities: \(res)")
            for entity in res {
                context.delete(entity)
            }
            try context.save()
            //            print("Saving context without the deleted entity")
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
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
        //        print(schedule)
        let weekString = schedule.map( { String($0.rawValue) }).joined(separator: " ")
        //        print(weekString)
        //        let stringSchedule = schedule.map(String).joined()
        return weekString
    }
    
    func stringToSchedule(scheduleString: String) -> [ScheduledDays] {
        //        print("stringToSchedule", scheduleString)
        //        var scheduledDaysArray = [ScheduledDays]()
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
        //        let weekString = schedule.map( { String($0.rawValue) }).joined(separator: " ")
        //        print(scheduledDaysArray)
        //        let stringSchedule = schedule.map(String).joined()
        return scheduledDaysArray
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
//        print("in controllerWillChangeContent")
//        let objects = controller.fetchedObjects
//        print(objects?.count)
//        let objects = controller.fetchedObjects
//        var insertedIndexes = IndexSet()
//        print(objects)
//    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
//        print("controllerDidChangeContent - Updated CoreData")
//        let objects = controller.fetchedObjects
//        print(objects?.count)
        guard let delegateTrackerForNotifications else {
//            print("no delegate")
            return
        }
        delegateTrackerForNotifications.addingTrackerOnScreen()
    }
    
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
    
}
