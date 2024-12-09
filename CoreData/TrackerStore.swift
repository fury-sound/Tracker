//
//  File.swift
//  Tracker
//
//  Created by Valery Zvonarev on 08.12.2024.
//

import UIKit
import CoreData

final class TrackerStore {
    private let context: NSManagedObjectContext
    //    private let uiColorMarshalling = UIColorMarshalling()
    
    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
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
        trackerCoreData.schedule = scheduleToString(schedule: tracker.schedule)
        trackerCoreData.color = tracker.color
        //        trackerCoreData.colorHex = uiColorMarshalling.hexString(from: mix.backgroundColor)
    }
    
    func retrieveAllTrackers() -> [Tracker] {
        let myRequest : NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        var allTrackerFromCoreData = [Tracker]()
        do {
            let res = try context.fetch(myRequest)
//            print("Entities: \(res)")
            for entity in res {
                //                print(entity.id, entity.name, entity.emojiPic, entity.color)
                allTrackerFromCoreData.append(Tracker(id: entity.id, name: entity.name, emojiPic: entity.emojiPic, color: entity.color as? UIColor, schedule: stringToSchedule(scheduleString: entity.schedule ?? "")))
            }
        } catch let error as NSError {
            print(error.description)
        }
        return allTrackerFromCoreData
    }
    
    func retrieveTracker(by id: UUID) -> Tracker? {
        var trackerToFind: Tracker?
        let myRequest : NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        myRequest.predicate = NSPredicate(format: "id == %@", "\(id)")
        
        do {
            let res = try context.fetch(myRequest)
            print("Entities: \(res)")
            for entity in res {
                //                guard let schedule = entity.schedule else { return trackerNext }
                //                print(entity.id, entity.name, entity.emojiPic, entity.color)
                trackerToFind = Tracker(id: entity.id, name: entity.name, emojiPic: entity.emojiPic, color: entity.color as? UIColor, schedule: stringToSchedule(scheduleString: entity.schedule ?? ""))
            }
        } catch let error as NSError {
            print(error.description)
        }
        return trackerToFind
    }
    
    func countEntities() {
        let myRequest : NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        do {
            let counter = try context.count(for: myRequest)
            //            print("Saved data? \(counter)")
        } catch let error as NSError {
            print(error.description)
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
            print(error.description)
        }
    }
    
    
    func deleteAllTrackerCoreDataEntities() {
        let myRequest : NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        //        myRequest.predicate = NSPredicate(format: "name == %@", "Mark")
        //        myRequest.predicate = NSPredicate()
        
        do {
            let res = try context.fetch(myRequest)
            print("Entities: \(res)")
            for entity in res {
                context.delete(entity)
            }
            
            try context.save()
            //            print("All entities deleted, saving context")
        } catch let error as NSError {
            print(error.description)
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
