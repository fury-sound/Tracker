//
//  MainNavigationBarViewController.swift
//  Tracker
//
//  Created by Valery Zvonarev on 02.11.2024.
//

import UIKit

final class MainTrackerViewController: UITabBarController {

    let trackerNaviVC = UINavigationController(rootViewController: TrackerNavigationViewController())
    let statisticsVC = UINavigationController(rootViewController: StatisticsTableViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainNavBarVC()
    }
    
    private func setupMainNavBarVC() {
//        view.backgroundColor = .white
  

//        let tabBarController = TrackerTabBarViewController()
//        trackerNaviVC.view.backgroundColor = .red

        trackerNaviVC.tabBarItem = UITabBarItem(title: "", image: UIImage.recordCircleFill, selectedImage: nil)
        statisticsVC.tabBarItem = UITabBarItem(title: "", image: UIImage.hareFill, selectedImage: nil)
//        trackerNaviVC.navigationBar.barStyle = .black
        self.viewControllers = [trackerNaviVC, statisticsVC]
//        let play = UIBarButtonItem(title: "Play", style: .plain, target: self, action: #selector(addHabit))
//
//        trackerNaviVC.navigationItem.leftBarButtonItem = play
//        trackerNaviVC.navigationItem.rightBarButtonItem
 
    }
    

    
    @objc func rightAddHabit() {
        print("adding right habit")
    }

    @objc func leftAddHabit() {
        print("adding left habit")
    }
}
