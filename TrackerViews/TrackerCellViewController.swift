//
//  TrackerCellViewController.swift
//  Tracker
//
//  Created by Valery Zvonarev on 10.11.2024.
//

import UIKit

final class TrackerCellViewController: UICollectionViewCell {
        
    private var trackerColor: UIColor = .blue
    
    private lazy var trackerView: UIView = {
        let trackerView = UIView()
//        trackerView.backgroundColor = trackerColor
        trackerView.layer.cornerRadius = 10
        return trackerView
    }()
    
    private lazy var emojiLabel: UILabel = {
        let emojiLabel = UILabel()
        emojiLabel.backgroundColor = .red
        emojiLabel.layer.cornerRadius = 30
        return emojiLabel
    }()
    
    private lazy var textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.backgroundColor = .clear
        textLabel.textColor = .ypWhite
//        textLabel.numberOfLines = 2
        textLabel.font = UIFont(name: "SFPro", size: 12)
//        textLabel.font = .systemFont(ofSize: 12, weight: .regular)
//        textLabel.font = UIFont(name: "SFPro", size: 32)
        return textLabel
    }()

    private lazy var daysLabel: UILabel = {
        let daysLabel = UILabel()
        daysLabel.backgroundColor = .clear
        daysLabel.text = "дней"
        return daysLabel
    }()
    
    private lazy var plusButton: UIButton = {
        let plusButton = UIButton()
        plusButton.setImage(UIImage.plusButton, for: .normal)
        plusButton.tintColor = .white
//        plusButton.backgroundColor = trackerColor
        plusButton.layer.cornerRadius = 17
        return plusButton
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        let elementArray = [trackerView, emojiLabel, textLabel, daysLabel, plusButton]
        elementArray.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
//        trackerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(trackerView)
        trackerView.addSubview(emojiLabel)
        trackerView.addSubview(textLabel)
        contentView.addSubview(daysLabel)
        contentView.addSubview(plusButton)
        NSLayoutConstraint.activate([
            trackerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerView.heightAnchor.constraint(equalToConstant: 2 * contentView.frame.height / 3),
            emojiLabel.topAnchor.constraint(equalTo: trackerView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
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

        

//        contentView.layer.cornerRadius = 15
//        contentView.layer.masksToBounds = true
//        plusButton.layer.cornerRadius = 30
//        plusButton.layer.masksToBounds = true
//        textLabel.layer.cornerRadius = 6
//        textLabel.layer.masksToBounds = true

//        textLabel.frame.size.height = 18
//        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
//        textLabel.translatesAutoresizingMaskIntoConstraints = false
//        daysLabel.translatesAutoresizingMaskIntoConstraints = false
//        plusButton.translatesAutoresizingMaskIntoConstraints = false

//        trackerView.addSubview(textLabel)
//        contentView.addSubview(daysLabel)
//        NSLayoutConstraint.activate([
//            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            textLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
//            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            daysLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            daysLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//            daysLabel.heightAnchor.constraint(equalToConstant: contentView.frame.height / 3)
//        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLabelText(text: String) {
        textLabel.text = text
    }
    
    func setEmoji(emoji: String) {
        emojiLabel.text = emoji
        emojiLabel.layer.cornerRadius = 10
    }
    
    func setTrackerColor(color: UIColor) {
        
        trackerView.backgroundColor = color
        plusButton.backgroundColor = color
    }
    
}
