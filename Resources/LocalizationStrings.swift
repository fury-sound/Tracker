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
let createButtonText = NSLocalizedString("Create", comment: "NewHabitVC, createOrSaveButtonText")
let saveButtonText = NSLocalizedString("Save", comment: "NewHabitVC, createOrSaveButtonText")
let newTrackerTitle = NSLocalizedString("New Habit", comment: "NewHabitVC, viewDidLoad")
let editTrackerTitle = NSLocalizedString("Edit the Habit", comment: "NewHabitVC, viewDidLoad")
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
let editEventTitle = NSLocalizedString("Edit the Event", comment: "NewEventVC, viewDidLoad")
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
let alertTitleForCategory = NSLocalizedString("Attention!", comment: "CategoryVC, tableTappedAlert, deleteCategoryAlert")
let changingPinnedCategory = NSLocalizedString("Category 'Pinned' cannot be edited. \n Use context menu to change this tracker category", comment: "CategoryVC, tableTappedAlert")
let deletingCategory = NSLocalizedString("Don't need this category? \n All related trackers to be deleted as well", comment: "CategoryVC, deleteCategoryAlert")
let deleteText = NSLocalizedString("Delete", comment: "CategoryVC, deleteCategoryAlert")
let cancelText = NSLocalizedString("Cancel", comment: "CategoryVC, deleteCategoryAlert")

//MARK: CategoryVCViewModel
let createCategoryText = NSLocalizedString("Create category", comment: "CategoryVCViewModel, viewDidLoad")
let addCategoryText = NSLocalizedString("Add category", comment: "CategoryVCViewModel, didSelectCategoryAtIndex")
let changeCategoryText = NSLocalizedString("Change category", comment: "CategoryVCViewModel, viewDidLoad")

//MARK: AddCategoryVC
let categoryNamePlaceholder = NSLocalizedString("Enter Category name", comment: "AddCategoryVC, trackerNameTextfield")
let newCategoryTitle = NSLocalizedString("New category", comment: "AddCategoryVC, viewDidLoad")
let editCategoryTitle = NSLocalizedString("Edit the category", comment: "AddCategoryVC, viewDidLoad")
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
let emptySearchText = NSLocalizedString("Nothing was found!", comment: "TrackerNavigationViewController, textForEmptySearch")
let pinActionText = NSLocalizedString("Pin", comment: "TrackerNavigationViewController, pinAction")
let unPinActionText = NSLocalizedString("Unpin", comment: "TrackerNavigationViewController, unpinAction")
let editActionText = NSLocalizedString("Edit", comment: "TrackerNavigationViewController, pinAction")
let deleteActionText = NSLocalizedString("Delete", comment: "TrackerNavigationViewController, pinAction")
let pinnedHeaderText = NSLocalizedString("Pinned", comment: "TrackerNavigationViewController, pinnedHeader")
let filterButtonText = NSLocalizedString("Filters", comment: "TrackerNavigationViewController, trackerFilters")

// MARK: MainTrackerViewController
let trackerBarName = NSLocalizedString("Trackers", comment: "MainTrackerViewController, setupMainNavBarVC")
let statisticsBarName = NSLocalizedString("Statistics", comment: "MainTrackerViewController, setupMainNavBarVC")

// MARK: TrackerCreateVC
let habitButtonName = NSLocalizedString("Habit", comment: "TrackerCreateVC, habitButton")
let eventButtonName = NSLocalizedString("Irregular event", comment: "TrackerCreateVC, eventButton")
let createTrackerTitle = NSLocalizedString("Creating a tracker", comment: "TrackerCreateVC, viewDidLoad")

// MARK: FiltersVC
let filterHeaderTitle = NSLocalizedString("Filters", comment: "FiltersVC, viewDidLoad")
let allTrackersTitle = NSLocalizedString("All trackers", comment: "FiltersVC, viewDidLoad")
let todayTrackersTitle = NSLocalizedString("Today trackers", comment: "FiltersVC, viewDidLoad")
let completedTrackersTitle = NSLocalizedString("Completed trackers", comment: "FiltersVC, viewDidLoad")
let uncompletedTrackersTitle = NSLocalizedString("Uncompleted trackers", comment: "FiltersVC, viewDidLoad")

// MARK: StatisticsTableViewController
let nothingToAnalyzeText = NSLocalizedString("Nothing to analyze yet", comment: "StatisticsTableViewController, nothingFoundLogo")
let statisticsTitle = NSLocalizedString("Statistics", comment: "StatisticsTableViewController, titleLabel")
let completedTrackersText = NSLocalizedString("completed trackers", comment: "StatisticsTableViewController, statisticsItemLabelBottom")


