//
//  EmojiCollectionViewController.swift
//  Tracker
//
//  Created by Valery Zvonarev on 27.11.2024.
//

import UIKit

final class EmojiCellCollectionViewController: UICollectionViewCell {
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let elementArray = [viewForEmoji, emojiLabel]
        elementArray.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        contentView.addSubview(emojiLabel)
        NSLayoutConstraint.activate([
            viewForEmoji.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            viewForEmoji.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            viewForEmoji.heightAnchor.constraint(equalToConstant: 52),
            viewForEmoji.widthAnchor.constraint(equalToConstant: 52),
            emojiLabel.centerXAnchor.constraint(equalTo: viewForEmoji.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: viewForEmoji.centerYAnchor),
            emojiLabel.heightAnchor.constraint(equalToConstant: 32),
            emojiLabel.widthAnchor.constraint(equalToConstant: 38)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
