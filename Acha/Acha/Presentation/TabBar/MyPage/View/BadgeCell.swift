//
//  BadgeCell.swift
//  Acha
//
//  Created by 조승기 on 2022/11/30.
//

import UIKit
import Then
import SnapKit
import RxSwift

final class BadgeCell: UICollectionViewCell {
    // MARK: - UI properties
    private lazy var badgeLabel: UILabel = UILabel().then {
        $0.font = .subBody
        $0.textAlignment = .center
    }
    private lazy var badgeImage: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 50
        $0.layer.borderWidth = 3
        $0.layer.borderColor = UIColor.pointLight.cgColor
        $0.clipsToBounds = true
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
            $0.top.centerX.equalToSuperview()
            $0.width.height.equalTo(100)
        }
        
        badgeLabel.snp.makeConstraints {
            $0.top.equalTo(badgeImage.snp.bottom).offset(5)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(20)
        }
    }
    
    func bind(image: String, badgeName: String, disposeBag: DisposeBag) {
        badgeImage.setImage(url: image, disposeBag: disposeBag)
        badgeLabel.text = badgeName
    }
}
