//
//  EmojiCollectionViewVC.swift
//  Tracker
//
//  Created by Valery Zvonarev on 28.11.2024.
//

import UIKit

final class EmojiCollectionViewVC: UIViewController {
    
    private let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🫢", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    
    
    let layout = UICollectionViewFlowLayout()
    
    lazy var emojiCollectionView: UICollectionView = {
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 5
        let emojiCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.register(CellCollectionViewController.self, forCellWithReuseIdentifier: "cellEmoji")
        return emojiCollectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emojiCollectionView.backgroundColor = .green
    }

    
}

// MARK: UICollectionViewDataSource, UICollectionViewDelegate

extension EmojiCollectionViewVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let emojiCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellEmoji", for: indexPath) as! CellCollectionViewController
        emojiCell.emojiLabel.backgroundColor = .blue
        emojiCell.emojiLabel.text = "\(emojis[indexPath.row])"
        return emojiCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

extension EmojiCollectionViewVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 30) / 6, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    

}

