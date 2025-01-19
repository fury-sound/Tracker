//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Valery Zvonarev on 19.01.2025.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testTrackerNavigationViewController() {
        
        let vc = TrackerNavigationViewController() as UIViewController
        assertSnapshots(of: vc, as: [.image] )
    }

}
