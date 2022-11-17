//
//  InGameMenuCollectionViewCell.swift
//  Acha
//
//  Created by hong on 2022/11/15.
//

import UIKit
import SnapKit
import Then

final class InGameMenuCollectionViewCell: UICollectionViewCell {
    // MARK: - UI properties
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillProportionally
        $0.spacing = 20
        $0.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        $0.isLayoutMarginsRelativeArrangement = true
    }
    private let extraImageView = UIImageView().then {
        $0.contentMode = .scaleToFill
    }
    private let contextLabel = UILabel().then {
        $0.font = .postBody
    }
    
    // MARK: - Properties
    static let identifier = "inGameCell"
    // MARK: - Lifecycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
      }
      required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
      }
    
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
    }
    
    private func addViews() {
        addSubview(stackView)
        stackView.addArrangedSubview(extraImageView)
        stackView.addArrangedSubview(contextLabel)
    }
    
    private func layoutViews() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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
            $0.trailing.equalTo(stackView.snp.trailing)
        }
    }
    
}

extension InGameMenuCollectionViewCell {
    func setData(image: UIImage?, text: String) {
        if case .some(let wrapped) = image {
            extraImageView.image = wrapped
        }
        contextLabel.text = text
    }
}
