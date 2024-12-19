//
//  TrackerCellViewController.swift
//  Tracker
//
//  Created by Valery Zvonarev on 10.11.2024.
//

import UIKit

final class TrackerCellViewController: UICollectionViewCell {
        
    private var trackerColorSet = [UIColor.ypDarkRed, UIColor.ypDarkBlue, UIColor.ypDarkGreen]
    private var colorNum: Int = 0
    var setMarkSign = false
    var tapped: (() -> Void)?
    
    private lazy var trackerView: UIView = {
        let trackerView = UIView()
        trackerView.layer.cornerRadius = 10
        trackerView.layer.masksToBounds = true
        return trackerView
    }()
    
    private lazy var emojiLabel: UILabel = {
        let emojiLabel = UILabel()
        emojiLabel.tintColor = .white
        emojiLabel.textAlignment = .center
        emojiLabel.font = .systemFont(ofSize: 14, weight: .regular)
        return emojiLabel
    }()
    
    private lazy var viewForEmoji: UIView = {
        let emojiView = UIView()
        emojiView.backgroundColor = .white
        emojiView.layer.opacity = 0.3
        emojiView.layer.cornerRadius = 12
        emojiView.layer.masksToBounds = true
        return emojiView
    }()
    
    private lazy var textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.backgroundColor = .clear
        textLabel.textColor = .ypWhite
        textLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        return textLabel
    }()

    private lazy var daysLabel: UILabel = {
        let daysLabel = UILabel()
        daysLabel.backgroundColor = .clear
        daysLabel.text = "0 дней"
        return daysLabel
    }()
    
    private lazy var plusButton: UIButton = {
        let plusButton = UIButton()
        let plusImage = UIImage(named: "plusButton")?.withRenderingMode(.alwaysTemplate)
        plusButton.setImage(plusImage, for: .normal)
        plusButton.tintColor = .ypWhite
        plusButton.addTarget(self, action: #selector(toggleButton), for: .touchUpInside)
        plusButton.layer.cornerRadius = 17
        return plusButton
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        let elementArray = [trackerView, viewForEmoji, emojiLabel, textLabel, daysLabel, plusButton]
        elementArray.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        contentView.addSubview(trackerView)
        trackerView.addSubview(viewForEmoji)
        trackerView.addSubview(textLabel)
        contentView.addSubview(daysLabel)
        contentView.addSubview(plusButton)
        contentView.addSubview(emojiLabel)
        NSLayoutConstraint.activate([
            trackerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerView.heightAnchor.constraint(equalToConstant: 2 * contentView.frame.height / 3),
            viewForEmoji.topAnchor.constraint(equalTo: trackerView.topAnchor, constant: 12),
            viewForEmoji.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            viewForEmoji.heightAnchor.constraint(equalToConstant: 27),
            viewForEmoji.widthAnchor.constraint(equalToConstant: 27),
            emojiLabel.centerXAnchor.constraint(equalTo: viewForEmoji.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: viewForEmoji.centerYAnchor),
            emojiLabel.heightAnchor.constraint(equalToConstant: 16),
            emojiLabel.widthAnchor.constraint(equalToConstant: 22),
            textLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            textLabel.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: 12),
            textLabel.bottomAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: -12),
            textLabel.heightAnchor.constraint(equalToConstant: 34),
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysLabel.topAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: 16),
            daysLabel.heightAnchor.constraint(equalToConstant: 18),
            plusButton.topAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: 8),
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            plusButton.widthAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setButtonSign(isPlusSignOnFlag: Bool) {
        if isPlusSignOnFlag {
            plusButton.setImage(.doneButton, for: .normal)
            plusButton.layer.opacity = 0.5
        } else {
            guard let image = UIImage(named: "plusButton") else {
                return
            }
            let signImage = image.withRenderingMode(.alwaysTemplate)
            plusButton.setImage(signImage, for: .normal)
            plusButton.tintColor = .ypWhite
//            plusButton.backgroundColor = trackerView.backgroundColor // trackerColorSet[colorNum]
            plusButton.layer.opacity = 1.0
        }
        
    }
    
    func enablingPlusButton() {
        plusButton.isEnabled = true
    }

    func disablingPlusButton() {
        plusButton.isEnabled = false
    }
    
    @objc func toggleButton(sender: AnyObject) {
        tapped?()
    }
    
    func setLabelText(text: String) {
        textLabel.text = text
    }
    
    func setEmoji(emoji: String) {
        emojiLabel.text = emoji
        emojiLabel.layer.cornerRadius = 10
    }
    
    func setDayLabelText(days: Int) {
        let dayEnding = properDayEndingsInRussian(num: days)
        daysLabel.text = "\(days) \(dayEnding)"
    }
    
    func properDayEndingsInRussian(num: Int) -> String {
        var lastNums = abs(num % 100)
        if lastNums >= 11 && lastNums <= 19 {
            return "дней"
        }
        lastNums = abs(num % 10)
        switch lastNums {
        case 1:
            return "день"
        case 2,3,4:
            return "дня"
        default:
            return "дней"
        }
    }
    
    func setColorsInCell(color: UIColor) {
//        colorNum = color
        trackerView.backgroundColor = color
        plusButton.backgroundColor = color
//        trackerView.backgroundColor = trackerColorSet[colorNum]
//        plusButton.backgroundColor = trackerColorSet[colorNum]
    }
}
