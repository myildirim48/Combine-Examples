//
//  DiceImageView.swift
//  DiceRoll-Combine
//
//  Created by YILDIRIM on 26.03.2023.
//


import UIKit
class DiceImageView: UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        tintColor = .systemOrange
        clipsToBounds = true
        contentMode = .scaleAspectFit
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 2
        layer.shadowOffset = .zero
        layer.cornerRadius = 8
    }
}
