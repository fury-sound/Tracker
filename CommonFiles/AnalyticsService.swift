//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Valery Zvonarev on 19.01.2025.
//

import Foundation
import YandexMobileMetrica

final class AnalyticsService {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "fe5ac413-4111-4d84-8b5b-9eab62fa5231") else { return }
        
        YMMYandexMetrica.activate(with: configuration)
    }
    
    func report(event: String, params : [AnyHashable : Any]) {
        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
    
    func sendEvent(event: String, screen: String, item: String? = nil) {
        var parameters: [String: Any] = [
            "event": event,
            "screen": screen
        ]
        if let item = item {
            parameters["item"] = item
        }

        YMMYandexMetrica.reportEvent("custom_event", parameters: parameters, onFailure: { error in
            print("Error reporting event: \(error.localizedDescription)")
        })
    }
}
