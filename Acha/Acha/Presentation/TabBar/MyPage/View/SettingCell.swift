//
//  SettingCell.swift
//  Acha
//
//  Created by  sangyeon on 2022/12/01.
//

import UIKit
import Then
import SnapKit

class SettingCell: UICollectionViewCell {
    // MARK: - UI properties
    private lazy var titleLabel: UILabel = UILabel().then {
        $0.font = .commentBody
        $0.textAlignment = .left
    }

    // MARK: - Properties
    static let identifer = "SettingCell"
    
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
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(10)
        }
    }
    
    func bind(title: String) {
        titleLabel.text = title
    }
}
