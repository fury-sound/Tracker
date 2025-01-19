//
//  GradientBorderView.swift
//  Tracker
//
//  Created by Valery Zvonarev on 19.01.2025.
//

import UIKit

final class GradientBorderView: UIView {
    private var gradientLayer: CAGradientLayer = CAGradientLayer()
    private var maskLayer: CAShapeLayer = CAShapeLayer()
    private var borderWidth: CGFloat
    private var cornerRadius: CGFloat
    private var colors: [UIColor]

    init(frame: CGRect, cornerRadius: CGFloat, borderWidth: CGFloat, colors: [UIColor]) {
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.colors = colors
        super.init(frame: frame)
        setupGradientLayer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupGradientLayer() {
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = cornerRadius
        layer.addSublayer(gradientLayer)

        maskLayer.lineWidth = borderWidth
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor.black.cgColor
        maskLayer.lineJoin = .round
        maskLayer.lineCap = .round
        gradientLayer.mask = maskLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds

        let inset = borderWidth / 2
        let path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: inset, dy: inset),
            cornerRadius: cornerRadius
        )
        maskLayer.path = path.cgPath
    }

}
