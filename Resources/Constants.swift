//
//  Constants.swift
//  Tracker
//
//  Created by Valery Zvonarev on 21.01.2025.
//

import UIKit

let EmojiArray = [ "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🥭", "🍎", "🍏", "🍐", "🍒", "🍓", "🫐", "🥝", "🍅", "🫒", "🥥", "🥑", "🍆", "🥔", "🥕", "🌽", "🌶️", "🫑", "🥒", "🥬", "🥦", "🧄", "🧅", "🍄"]
let Colors: [UIColor] = [.ypDarkRed, .ypOrange, .ypDarkBlue, .ypAmethyst, .ypGreen, .ypOrchid, .ypPastelPink, .ypLightBlue, .ypLightGreen, .ypCosmicCobalt, .ypRed, .ypPaleMagentaPink, .ypMacaroniAndCheese, .ypCornflowerBlue, .ypBlueViolet, .ypMediumOrchid, .ypMediumPurple, .ypDarkGreen]
let maxStringToTypeLength = 38
let rowHeightForTables: CGFloat = 75

typealias BoolClosure = ((Bool) -> Void)
typealias StringClosure = ((String) -> Void)
typealias EmptyClosure = (() -> Void)
//    typealias UIStateClosure = (viewControllerState) -> Void

