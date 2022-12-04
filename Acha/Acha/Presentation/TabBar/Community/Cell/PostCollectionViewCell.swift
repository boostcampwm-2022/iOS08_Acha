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
    
    static let identifier = "PostDetailCollectionViewCell"
    
    private lazy var contextLabel = UILabel().then {
        $0.font = .body
        $0.textColor = .black
        $0.numberOfLines = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(data: Post) {
        contextLabel.text = data.text
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
