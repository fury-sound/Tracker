//
//  SupplementaryHeaderView.swift
//  Tracker
//
//  Created by Valery Zvonarev on 23.11.2024.
//

import UIKit

final class SupplementaryHeaderView: UICollectionReusableView {
    
    let headerLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        addSubview(headerLabel)
        headerLabel.font = .systemFont(ofSize: 19, weight: .bold)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
//            headerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            headerLabel.topAnchor.constraint(equalTo: topAnchor),
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
