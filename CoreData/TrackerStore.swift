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
    private var trackerCategoryStore: TrackerCategoryStore?
    
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
//        self.trackerCategoryStore = TrackerCategoryStore(context: context)
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
    
    func editTrackerInCoreData(_ tracker: Tracker) throws {
//        let trackerCoreData = TrackerCoreData(context: context)
        let myRequest : NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "id == %@", tracker.id! as CVarArg)
        do {
            let res = try context.fetch(myRequest)
            let editedEntity = res.first
            guard let editedEntity else { return }
            editedEntity.name = tracker.name
            editedEntity.emojiPic = tracker.emojiPic
            editedEntity.color = tracker.color
            if tracker.schedule.isEmpty {
                editedEntity.schedule = ""
            } else {
                editedEntity.schedule = scheduleToString(schedule: tracker.schedule)
            }
            try context.save()
        } catch let error as NSError {
            print("Error with adding tracker to CoreData in addTrackerToCoreData, TrackerStore:", error.localizedDescription, error.code, error.userInfo)
        }
    }
    
    func addTrackerToCoreData(_ tracker: Tracker) throws -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: context)
        updateTrackerList(trackerCoreData, with: tracker)
        do {
            try context.save()
        } catch let error as NSError {
            print("Error with adding tracker to CoreData in addTrackerToCoreData, TrackerStore:", error.localizedDescription, error.code, error.userInfo)
        }
        return trackerCoreData
    }
    
    func pinTrackerToCoreData(_ tracker: Tracker) throws -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: context)
//        updateTrackerList(trackerCoreData, with: tracker)
//        trackerCoreData.isPinned = true
//        do {
//            try context.setValue(true, forKey: "isPinned")
//        }
        return TrackerCoreData()
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
            for entity in res {
                if entity.schedule == "" {
                    let arr: [ScheduledDays] = []
                    allTrackerFromCoreData.append(Tracker(id: entity.id, name: entity.name, emojiPic: entity.emojiPic, color: entity.color as? UIColor, schedule: arr))
                } else {
                    allTrackerFromCoreData.append(Tracker(id: entity.id, name: entity.name, emojiPic: entity.emojiPic, color: entity.color as? UIColor, schedule: stringToSchedule(scheduleString: entity.schedule ?? "")))
                }
            }
        } catch let error as NSError {
            print("Error retrieving trackers in retrieveAllTrackers(), TrackerStore", error.localizedDescription)
        }
        return allTrackerFromCoreData
    }
    
    func retrieveTrackerCategoryByID(by id: UUID) -> String? {
        let myRequest : NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "id == %@", "\(id)")
        do {
            let res = try context.fetch(myRequest)
            for entity in res {
                return entity.category?.title
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func retrieveTrackerByID(by id: UUID) -> Tracker? {
        var trackerToFind: Tracker?
        let myRequest : NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "id == %@", "\(id)")
        
        do {
            let res = try context.fetch(myRequest)
            for entity in res {
                print("Tracker name: \(entity.name), \(entity.id)")
                print("Tracker category: \(entity.category?.title)")
                print("Tracker pinned: \(entity.isPinned)")
//                entity.isPinned = entity.category?.title
//                entity.category?.title = "Pinned"
//                print("Tracker category: \(entity.category?.title)")
//                print("Tracker pinned - stored category: \(entity.isPinned)")
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return trackerToFind
    }
    
    
    // MARK: switchTrackerCategories
    func switchTrackerCategories(by id: UUID) {
//        var trackerToFind: Tracker?
        let trackerCategoryStore = TrackerCategoryStore(context: context)
        let myRequest : NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "id == %@", "\(id)")
        do {
            let res = try context.fetch(myRequest)
            for entity in res {
                guard let mainCategoryTitle = entity.category?.title, let isPinned = entity.isPinned else { return }
//                print("1")
//                print("Tracker name: \(String(describing: entity.name)), \(String(describing: entity.id))")
//                print("Tracker category: \(String(describing: entity.category?.title))")
//                print("Tracker pinned: \(String(describing: entity.isPinned))")
//                trackerCategoryStore.retrieveCategoryTitles()
//                if entity.isPinned == "Pinned" {
                    trackerCategoryStore.switchTrackerCategory(trackerCoreData: entity, categoryField: mainCategoryTitle, isPinnedField: isPinned)
                    entity.isPinned = mainCategoryTitle
//                } else {
//                    trackerCategoryStore.switchTrackerCategory(trackerCoreData: entity, categoryField: isPinned, isPinnedField: mainCategoryTitle)
//                    entity.isPinned = isPinned
//                }
//                print("2")
//                print("Tracker name: \(String(describing: entity.name)), \(String(describing: entity.id))")
//                print("Tracker category: \(String(describing: entity.category?.title))")
//                print("Tracker pinned: \(String(describing: entity.isPinned))")
            }
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func isPinnedState(by id: UUID) -> String? {
        let myRequest : NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "id == %@", "\(id)")
        do {
            let res = try context.fetch(myRequest)
            return res.first?.isPinned ?? ""
        } catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
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
    
    func filterTrackersByWeekday(dayOfWeek: Int) -> [String: [Tracker]]? {
//        var arrayForTrackers = [Tracker]()
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
//                if entity.trackerRecord?.dateExecuted != nil {
//                    print("Found in TrackerRecord - entity.name, entity.trackerRecord?.id, entity.trackerRecord?.dateExecuted", entity.name, entity.trackerRecord?.id, entity.trackerRecord?.dateExecuted)
//                } else {
//                    print("Not completed for the date")
//                }
                if entity.schedule == "" {
//                    arrayForTrackers.append(Tracker(id: entity.id, name: entity.name, emojiPic: entity.emojiPic, color: entity.color as? UIColor, schedule: arr))
                    dictionaryForTrackerCategory[categoryTitle]?.append(Tracker(id: entity.id, name: entity.name, emojiPic: entity.emojiPic, color: entity.color as? UIColor, schedule: arr))
                } else {
//                    arrayForTrackers.append(Tracker(id: entity.id, name: entity.name, emojiPic: entity.emojiPic, color: entity.color as? UIColor, schedule: stringToSchedule(scheduleString: entity.schedule ?? "")))
                    dictionaryForTrackerCategory[categoryTitle]?.append(Tracker(id: entity.id, name: entity.name, emojiPic: entity.emojiPic, color: entity.color as? UIColor, schedule: stringToSchedule(scheduleString: entity.schedule ?? "")))
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return dictionaryForTrackerCategory
    }
    
    func filterTrackersByWeekdayForTrackerCoreData(dayOfWeek: Int, trackerCoreData: TrackerCoreData) -> [Tracker] {
        var arrayForTrackers = [Tracker]()
        let arr: [ScheduledDays] = []
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
    
    // temp function
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
    
    // temp function
    func deleteAllTrackerCoreDataEntities() {
        let myRequest : NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        //        myRequest.predicate = NSPredicate(format: "name == %@", "Mark")
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

