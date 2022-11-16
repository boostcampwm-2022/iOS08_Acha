//
//  InGameMenuCollectionViewCell.swift
//  Acha
//
//  Created by hong on 2022/11/15.
//

import UIKit
import SnapKit
import Then

class InGameMenuCollectionViewCell: UICollectionViewCell {
    // MARK: - UI properties
    private let stackView = UIStackView()
    private let extraImageView = UIImageView().then {
        $0.contentMode = .scaleToFill
    }
    private let contextLabel = UILabel().then {
        $0.font = FontConstants.inGameContextFont
    }
    
    // MARK: - Properties
    static let cellId = "inGameCell"
    // MARK: - Lifecycles
    override func prepareForReuse() {
        super.prepareForReuse()
        extraImageView.image = nil
        contextLabel.text = ""
    }
    
}
// MARK: - Helpers
extension InGameMenuCollectionViewCell {
    private func layout() {
        addViews()
        layoutViews()
        stackViewSetting()
    }
    
    private func addViews() {
        addSubview(stackView)
        stackView.addArrangedSubview(extraImageView)
        stackView.addArrangedSubview(contextLabel)
    }
    
    private func layoutViews() {
        stackView.snp.makeConstraints {
            $0.top.equalTo(snp.top)
            $0.bottom.equalTo(snp.bottom)
            $0.leading.equalTo(snp.leading)
            $0.trailing.equalTo(snp.trailing)
        }

        extraImageView.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.top)
            $0.bottom.equalTo(stackView.snp.bottom)
            $0.width.lessThanOrEqualTo(60)
        }

        contextLabel.snp.makeConstraints {
            $0.leading.equalTo(extraImageView.snp.trailing)
            $0.top.equalTo(stackView.snp.top)
            $0.bottom.equalTo(stackView.snp.bottom)
            $0.trailing.equalTo(snp.trailing)
        }
    }
    
    private func stackViewSetting() {
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 20
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
    }
}

extension InGameMenuCollectionViewCell {
    func setData(image: UIImage?, text: String) {
        layout()
        if case .some(let wrapped) = image {
            extraImageView.image = wrapped
        }
        contextLabel.text = text
    }
}
