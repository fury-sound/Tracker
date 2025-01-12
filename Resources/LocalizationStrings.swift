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
        return String(localized: "\(days) days", comment: "TrackerCellViewController, setDayLabelText()")
//        return String(localized: "\(days) days", table: tableNameForLocalizableCatalog, comment: "setDayLabelText(), TrackerCellViewController")
    } else {
        return NSLocalizedString(keyForLocalizableDictionary, tableName: "LocalizableDictionary", comment: "TrackerCellViewController, setDayLabelText()")
    }
}

//MARK: OnboardingViewController

let labelLeftText = NSLocalizedString("Follow only \n what you need", comment: "OnboardingViewController, labelLeftText")
let labelRightText = NSLocalizedString("Even if it's not about \n amount of water or yoga", comment: "OnboardingViewController, labelRightText")
let buttonText = NSLocalizedString("Truly hi-tech!", comment: "OnboardingViewController, wowButton")

//MARK: NewHabitVC
let trackerCategory = NSLocalizedString("Category", comment: "NewHabitVC, buttonNameArray")
let trackerCategoryName = NSLocalizedString("Category name", comment: "NewHabitVC, buttonNameArray")
let trackerSchedule = NSLocalizedString("Schedule", comment: "NewHabitVC, buttonNameArray")
let trackersDaysOfWeek = NSLocalizedString("Days of week", comment: "NewHabitVC, buttonNameArray")
let defaultHeaderName = NSLocalizedString("Important", comment: "NewHabitVC, defaultHeader")
let trackerNamePlaceholder = NSLocalizedString("Enter Tracker name", comment: "NewHabitVC, trackerNameTextfield")
let cancelButtonText = NSLocalizedString("Cancel", comment: "NewHabitVC, cancelButtonText")
let createButtonText = NSLocalizedString("Create", comment: "NewHabitVC, createButtonText")
let newTrackerTitle = NSLocalizedString("New Habit", comment: "NewHabitVC, viewDidLoad")
let returnedEveryDay = NSLocalizedString("Every day", comment: "NewHabitVC, intsToDaysOfWeek")
let trackerCategoryPlaceholder = NSLocalizedString("Category name", comment: "NewHabitVC, cellForRowAt")
let trackerWeekdayPlaceholder = NSLocalizedString("Days of week", comment: "NewHabitVC, cellForRowAt")
let headerTextForColor = NSLocalizedString("Color", comment: "NewHabitVC, viewForSupplementaryElementOfKind")

//MARK: NewEventVC

let eventsTitle = NSLocalizedString("Irregular events", comment: "NewEventVC, buttonNameArray")
let eventsName = NSLocalizedString("Event category", comment: "NewEventVC, buttonNameArray")
//let defaultHeaderNameEvent = NSLocalizedString("Important", comment: "NewEventVC, defaultHeader")
let eventNamePlaceholder = NSLocalizedString("Enter Event name", comment: "NewEventVC, eventNameTextfield")
//let cancelButtonText = NSLocalizedString("Cancel", comment: "NewEventVC, cancelButtonText")
//let createButtonText = NSLocalizedString("Create", comment: "NewEventVC, createButtonText")
let newEventTitle = NSLocalizedString("New Event", comment: "NewEventVC, viewDidLoad")
let eventCategoryPlaceholder = NSLocalizedString("Category name", comment: "NewEventVC, cellForRowAt")
//let headerTextForColor = NSLocalizedString("Color", comment: "NewEventVC, viewForSupplementaryElementOfKind")

//MARK: ScheduleVC
let monday = NSLocalizedString("Monday", comment: "ScheduleVC, weekdayArray")
let tuesday = NSLocalizedString("Tuesday", comment: "ScheduleVC, weekdayArray")
let wednesday = NSLocalizedString("Wednesday", comment: "ScheduleVC, weekdayArray")
let thursday = NSLocalizedString("Thursday", comment: "ScheduleVC, weekdayArray")
let friday = NSLocalizedString("Friday", comment: "ScheduleVC, weekdayArray")
let saturday = NSLocalizedString("Saturday", comment: "ScheduleVC, weekdayArray")
let sunday = NSLocalizedString("Sunday", comment: "ScheduleVC, weekdayArray")
let readyButtonText = NSLocalizedString("Ready", comment: "ScheduleVC, readyButton")
let scheduleTitle = NSLocalizedString("Schedule", comment: "ScheduleVC, viewDidLoad")

//MARK: CategoryVC
let initSloganText = NSLocalizedString("Trackers and events \n can be combined", comment: "CategoryVC, initSlogan")
let categoryTitle = NSLocalizedString("Category", comment: "CategoryVC, viewDidLoad").localizedCapitalized

//MARK: CategoryVCViewModel
let createCategoryText = NSLocalizedString("Create category", comment: "CategoryVCViewModel, viewDidLoad")
let addCategoryText = NSLocalizedString("Add category", comment: "CategoryVCViewModel, didSelectCategoryAtIndex")

//MARK: AddCategoryVC
let categoryNamePlaceholder = NSLocalizedString("Enter Category name", comment: "AddCategoryVC, trackerNameTextfield")
let newCategoryTitle = NSLocalizedString("New category", comment: "AddCategoryVC, viewDidLoad")
let alertTitle = NSLocalizedString("Error!\n", comment: "AddCategoryVC, alertForAddCategoryError")
let keyCategoryExists = NSLocalizedString("Such category already exists!", comment: "AddCategoryVC, alertForAddCategoryError")


//func alertMessage(name: String) -> String {
//    let curName = name
////    let keyCategoryExists = NSLocalizedString( = "Category \(curName) already exists!"
//    let keyCategoryExists = NSLocalizedString( = "Category \(curName) already exists!"
//    let keyCategoryExistsFinal = String(format: keyCategoryExists, curName)
//    return NSLocalizedString(keyCategoryExistsFinal, comment: "AddCategoryVC, alertForAddCategoryError")
//}
//let readyButtonText = NSLocalizedString("Ready", comment: "AddCategoryVC, readyButton")

// MARK: TrackerNavigationViewController
let searchBarPlaceholder = NSLocalizedString("Search", comment: "TrackerNavigationViewController, searchBar")
let initLogoText = NSLocalizedString("What you gonna track?", comment: "TrackerNavigationViewController, initLogo")
let naviBarTitle = NSLocalizedString("Trackers", comment: "TrackerNavigationViewController, naviBarSetup")

// MARK: MainTrackerViewController
let trackerBarName = NSLocalizedString("Trackers", comment: "MainTrackerViewController, setupMainNavBarVC")
let statisticsBarName = NSLocalizedString("Statistics", comment: "MainTrackerViewController, setupMainNavBarVC")

// MARK: TrackerCreateVC
let habitButtonName = NSLocalizedString("Habit", comment: "TrackerCreateVC, habitButton")
let eventButtonName = NSLocalizedString("Irregular event", comment: "TrackerCreateVC, eventButton")
let createTrackerTitle = NSLocalizedString("Creating a tracker", comment: "TrackerCreateVC, viewDidLoad")


