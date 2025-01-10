//
//  LocalizationStrings.swift
//  Tracker
//
//  Created by Valery Zvonarev on 10.01.2025.
//

import UIKit

//MARK: TrackerCellViewController

//@available(iOS 15, *)
//let tableNameForLocalizableCatalog: String = "LocalizableCatalog"
let keyForLocalizableDictionary: String = "numberOfDays"

func setNumberOfDaysLabelText(days: Int) -> String {
    if #available(iOS 15, *) {
//        print("for IOS 15")
        return String(localized: "\(days) days", comment: "TrackerCellViewController, setDayLabelText()")
//        return String(localized: "\(days) days", table: tableNameForLocalizableCatalog, comment: "setDayLabelText(), TrackerCellViewController")
    } else {
//        print("before iOS 15")
        return NSLocalizedString(keyForLocalizableDictionary, tableName: "LocalizableDictionary", comment: "TrackerCellViewController, setDayLabelText()")
    }
}

//MARK: OnboardingViewController

let labelLeftText = NSLocalizedString("Follow only \n what you need", comment: "OnboardingViewController, labelLeftText").localizedCapitalized
let labelRightText = NSLocalizedString("Even if it's \n not amount of water or yoga", comment: "OnboardingViewController, labelRightText").localizedCapitalized
//let labelLeftText = NSLocalizedString("Follow only what you need", comment: "OnboardingViewController, labelLeftText").localizedCapitalized
//let labelRightText = NSLocalizedString("Even if it's not amount of water or yoga", comment: "OnboardingViewController, labelRightText").localizedCapitalized
let buttonText = NSLocalizedString("Truly hi-tech!", comment: "OnboardingViewController, wowButton").localizedCapitalized

//MARK: NewHabitVC
let trackerCategory = NSLocalizedString("Category", comment: "NewHabitVC, buttonNameArray").localizedCapitalized
let trackerCategoryName = NSLocalizedString("Category name", comment: "NewHabitVC, buttonNameArray").localizedCapitalized
let trackerSchedule = NSLocalizedString("Schedule", comment: "NewHabitVC, buttonNameArray").localizedCapitalized
let trackersDaysOfWeek = NSLocalizedString("Days of week", comment: "NewHabitVC, buttonNameArray").localizedCapitalized
let defaultHeaderName = NSLocalizedString("Important", comment: "NewHabitVC, defaultHeader").localizedCapitalized
let trackerNamePlaceholder = NSLocalizedString("Enter Tracker name", comment: "NewHabitVC, trackerNameTextfield").localizedCapitalized
let cancelButtonText = NSLocalizedString("Cancel", comment: "NewHabitVC, cancelButtonText").localizedCapitalized
let createButtonText = NSLocalizedString("Create", comment: "NewHabitVC, createButtonText").localizedCapitalized
let newTrackerTitle = NSLocalizedString("New Habit", comment: "NewHabitVC, viewDidLoad").localizedCapitalized
let returnedEveryDay = NSLocalizedString("Every day", comment: "NewHabitVC, intsToDaysOfWeek").localizedCapitalized
let trackerCategoryPlaceholder = NSLocalizedString("Category name", comment: "NewHabitVC, cellForRowAt").localizedCapitalized
let trackerWeekdayPlaceholder = NSLocalizedString("Days of week", comment: "NewHabitVC, cellForRowAt").localizedCapitalized
let headerTextForColor = NSLocalizedString("Color", comment: "NewHabitVC, viewForSupplementaryElementOfKind").localizedCapitalized

//MARK: NewEventVC

let eventsTitle = NSLocalizedString("Irregular events", comment: "NewEventVC, buttonNameArray").localizedCapitalized
let eventsName = NSLocalizedString("Event category", comment: "NewEventVC, buttonNameArray").localizedCapitalized
//let defaultHeaderNameEvent = NSLocalizedString("Important", comment: "NewEventVC, defaultHeader")
let eventNamePlaceholder = NSLocalizedString("Enter Event name", comment: "NewEventVC, eventNameTextfield").localizedCapitalized
//let cancelButtonText = NSLocalizedString("Cancel", comment: "NewEventVC, cancelButtonText")
//let createButtonText = NSLocalizedString("Create", comment: "NewEventVC, createButtonText")
let newEventTitle = NSLocalizedString("New Event", comment: "NewEventVC, viewDidLoad").localizedCapitalized
let eventCategoryPlaceholder = NSLocalizedString("Category name", comment: "NewEventVC, cellForRowAt").localizedCapitalized
//let headerTextForColor = NSLocalizedString("Color", comment: "NewEventVC, viewForSupplementaryElementOfKind")

//MARK: ScheduleVC
let monday = NSLocalizedString("Monday", comment: "ScheduleVC, weekdayArray").localizedCapitalized
let tuesday = NSLocalizedString("Tuesday", comment: "ScheduleVC, weekdayArray").localizedCapitalized
let wednesday = NSLocalizedString("Wednesday", comment: "ScheduleVC, weekdayArray").localizedCapitalized
let thursday = NSLocalizedString("Thursday", comment: "ScheduleVC, weekdayArray").localizedCapitalized
let friday = NSLocalizedString("Friday", comment: "ScheduleVC, weekdayArray").localizedCapitalized
let saturday = NSLocalizedString("Saturday", comment: "ScheduleVC, weekdayArray").localizedCapitalized
let sunday = NSLocalizedString("Sunday", comment: "ScheduleVC, weekdayArray").localizedCapitalized
let readyButtonText = NSLocalizedString("Ready", comment: "ScheduleVC, readyButton").localizedCapitalized
let scheduleTitle = NSLocalizedString("Schedule", comment: "ScheduleVC, viewDidLoad").localizedCapitalized

//MARK: CategoryVC
let initSloganText = NSLocalizedString("Trackers and events \n can be combined", comment: "CategoryVC, initSlogan").localizedCapitalized
let categoryTitle = NSLocalizedString("Category", comment: "CategoryVC, viewDidLoad").localizedCapitalized

//MARK: CategoryVCViewModel
let createCategoryText = NSLocalizedString("Create category", comment: "CategoryVCViewModel, viewDidLoad").localizedCapitalized
let addCategoryText = NSLocalizedString("Add category", comment: "CategoryVCViewModel, didSelectCategoryAtIndex").localizedCapitalized

//MARK: AddCategoryVC
let categoryNamePlaceholder = NSLocalizedString("Enter Category name", comment: "AddCategoryVC, trackerNameTextfield").localizedCapitalized
let newCategoryTitle = NSLocalizedString("New category", comment: "AddCategoryVC, viewDidLoad").localizedCapitalized
let alertTitle = NSLocalizedString("Error!\n", comment: "AddCategoryVC, alertForAddCategoryError").localizedCapitalized
let keyCategoryExists = NSLocalizedString("Such category already exists!", comment: "AddCategoryVC, alertForAddCategoryError").localizedCapitalized


//func alertMessage(name: String) -> String {
//    let curName = name
////    let keyCategoryExists = NSLocalizedString( = "Category \(curName) already exists!"
//    let keyCategoryExists = NSLocalizedString( = "Category \(curName) already exists!"
//    let keyCategoryExistsFinal = String(format: keyCategoryExists, curName)
//    return NSLocalizedString(keyCategoryExistsFinal, comment: "AddCategoryVC, alertForAddCategoryError")
//}
//let readyButtonText = NSLocalizedString("Ready", comment: "AddCategoryVC, readyButton")

// MARK: TrackerNavigationViewController

//let searchBarPlpaceholder = NSLocalizedString("Search", comment: "TrackerNavigationViewController, searchBar").localizedCapitalized
//let initLogoText = NSLocalizedString("What you gonna track?", comment: "TrackerNavigationViewController, initLogo").localizedCapitalized
//let naviBarTitle = NSLocalizedString("Trackers", comment: "TrackerNavigationViewController, naviBarSetup").localizedCapitalized
let searchBarPlpaceholder = NSLocalizedString("Search", comment: "TrackerNavigationViewController, searchBar")
let initLogoText = NSLocalizedString("What you gonna track?", comment: "TrackerNavigationViewController, initLogo")
let naviBarTitle = NSLocalizedString("Trackers", comment: "TrackerNavigationViewController, naviBarSetup")

// MARK: MainTrackerViewController
//let trackerBarName = NSLocalizedString("Trackers", comment: "MainTrackerViewController, setupMainNavBarVC").localizedCapitalized
//let statisticsBarName = NSLocalizedString("Statistics", comment: "MainTrackerViewController, setupMainNavBarVC").localizedCapitalized
let trackerBarName = NSLocalizedString("Trackers", comment: "MainTrackerViewController, setupMainNavBarVC")
let statisticsBarName = NSLocalizedString("Statistics", comment: "MainTrackerViewController, setupMainNavBarVC")

// MARK: TrackerCreateVC
let habitButtonName = NSLocalizedString("Habit", comment: "TrackerCreateVC, habitButton").localizedCapitalized
let eventButtonName = NSLocalizedString("Irregular event", comment: "TrackerCreateVC, eventButton").localizedCapitalized
let createTrackerTitle = NSLocalizedString("Creating a tracker", comment: "TrackerCreateVC, viewDidLoad").localizedCapitalized


