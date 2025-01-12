//
//  TrackerColors.swift
//  Tracker
//
//  Created by Valery Zvonarev on 11.01.2025.
//

import UIKit

final class TrackerColors {
    static let viewBackgroundColor = UIColor.systemBackground
    static let backgroundButtonColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor.ypBlack
        } else {
            return UIColor.ypWhite
        }
    }
    static let buttonTintColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor.ypWhite
        } else {
            return UIColor.ypBlack
        }
    }
    
//    staticlet buttonDisabledBackgroundColor = UIColor { (traits: UITraitCollection) -> UIColor in
//        if traits.userInterfaceStyle == .light {
//            return UIColor.ypGray                                    // светлый режим
//        } else {
//            return UIColor(red: 0.8, green: 0.5, blue: 0.8, alpha: 1)   // тёмный режим
//        }
//    }
    
    static func setPlaceholderTextColor(textField: UITextField) {
//        let placeholderText = "What you gonna track?"
        let placeholderText = textField.placeholder ?? ""
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.ypGray // Change to your desired color
        ]
        let attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        textField.attributedPlaceholder = attributedPlaceholder
    }
}
