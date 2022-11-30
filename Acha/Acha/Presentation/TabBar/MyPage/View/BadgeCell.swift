//
//  BadgeCell.swift
//  Acha
//
//  Created by 조승기 on 2022/11/30.
//

import UIKit
import Then
import SnapKit

class BadgeCell: UICollectionViewCell {
    // MARK: - UI properties
    private lazy var badgeLabel: UILabel = UILabel().then {
        $0.font = .subBody
        $0.textAlignment = .center
    }
    private lazy var badgeImage: UIImageView = UIImageView().then {
        $0.contentMode = .scaleToFill
        $0.layer.cornerRadius = 50
    }
    // MARK: - Properties
    static let identifer = "BadgeCell"
    
    // MARK: - Lifecycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Helpers
    private func setupSubviews() {
        [badgeLabel, badgeImage].forEach { addSubview($0) }
        
        badgeImage.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.width.equalTo(100)
        }
        
        badgeLabel.snp.makeConstraints {
            $0.top.equalTo(badgeImage).offset(5)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func bind(image: UIImage, badgeName: String) {
        badgeImage.image = image
        badgeLabel.text = badgeName
    }
}
