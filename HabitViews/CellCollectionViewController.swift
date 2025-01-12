//
//  EmojiCollectionViewController.swift
//  Tracker
//
//  Created by Valery Zvonarev on 27.11.2024.
//

import UIKit

final class CellCollectionViewController: UICollectionViewCell {
        
    lazy var emojiLabel: UILabel = {
        let emojiLabel = UILabel()
        emojiLabel.backgroundColor = .clear
        emojiLabel.textAlignment = .center
        emojiLabel.font = .systemFont(ofSize: 36, weight: .heavy)
        return emojiLabel
    }()
    
    lazy var viewForItem: UIView = {
        let emojiView = UIView()
        emojiView.backgroundColor = TrackerColors.viewBackgroundColor
//        emojiView.sizeToFit()
//        emojiView.frame.size.height = cellSize
//        emojiView.frame.size.width = cellSize
        emojiView.layer.opacity = 0.3
        emojiView.layer.cornerRadius = 12
        emojiView.layer.masksToBounds = true
        return emojiView
    }()

    private lazy var colorView: UIView = {
        let colorView = UIView()
        colorView.backgroundColor = .ypGray
//        emojiView.sizeToFit()
//        emojiView.frame.size.height = cellSize
//        emojiView.frame.size.width = cellSize
//        colorView.layer.opacity = 0.3
        colorView.layer.cornerRadius = 12
        colorView.layer.masksToBounds = true
        return colorView
    }()
    
    var cellSize: CGFloat = 0
    var emojiImageText = ""
    var itemColor = UIColor()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setEmojiImage(text: String) {
        emojiImageText = text
    }
    
    func setItemColor(color: UIColor) {
        itemColor = color
    }
    
    func setImageViewColor(section: Int) {
        if section == 0 {
            viewForItem.backgroundColor = .ypLightGray
        } else {
            viewForItem.layer.borderColor = itemColor.cgColor //UIColor.ypGreen.cgColor
            viewForItem.layer.borderWidth = 3.0
        }
    }
    
    func unsetImageViewColor(section: Int) {
        if section == 0 {
            viewForItem.backgroundColor = TrackerColors.viewBackgroundColor
        } else {
            viewForItem.layer.borderColor = .none
            viewForItem.layer.borderWidth = .zero
        }
    }

    func setCellSize(size: CGFloat, section: Int) {
                                    
        if section == 0 {
            cellSize = (size / 1.5)
            let elementArray = [viewForItem, emojiLabel]
            elementArray.forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview($0)
            }
            NSLayoutConstraint.activate([
                viewForItem.topAnchor.constraint(equalTo: contentView.topAnchor),
                viewForItem.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                viewForItem.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                viewForItem.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                emojiLabel.centerXAnchor.constraint(equalTo: viewForItem.centerXAnchor),
                emojiLabel.centerYAnchor.constraint(equalTo: viewForItem.centerYAnchor),
                emojiLabel.heightAnchor.constraint(equalToConstant: cellSize - 6),
                emojiLabel.widthAnchor.constraint(equalToConstant: cellSize)
            ])
            emojiLabel.text = emojiImageText
        } else {
            cellSize = (size / 1.3)
            let elementArray = [viewForItem, colorView]
            elementArray.forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview($0)
            }
            NSLayoutConstraint.activate([
                viewForItem.topAnchor.constraint(equalTo: contentView.topAnchor),
                viewForItem.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                viewForItem.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                viewForItem.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                colorView.centerXAnchor.constraint(equalTo: viewForItem.centerXAnchor),
                colorView.centerYAnchor.constraint(equalTo: viewForItem.centerYAnchor),
                colorView.heightAnchor.constraint(equalToConstant: cellSize),
                colorView.widthAnchor.constraint(equalToConstant: cellSize)
            ])
            colorView.backgroundColor = itemColor
        }
    }
    
    
}
