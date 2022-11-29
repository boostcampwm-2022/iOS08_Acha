//
//  PostCollectionViewCell.swift
//  Acha
//
//  Created by hong on 2022/11/29.
//

import UIKit
import Then
import SnapKit

final class PostCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PostCollectionViewCell"
    
    private lazy var contextLabel = UILabel().then {
        $0.font = .body
        $0.textColor = .black
        $0.numberOfLines = 0
    }
    
    init() {
        super.init(frame: .zero)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PostCollectionViewCell {
    private func layout() {
        addViews()
        addConstraints()
    }
    
    private func addViews() {
        addSubview(contextLabel)
    }
    
    private func addConstraints() {
        contextLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
