//
//  CommentHeaderCollectionReusableView.swift
//  Acha
//
//  Created by hong on 2022/11/29.
//

import UIKit

final class CommentHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "CommentHeader"
    
    private lazy var commentLabel = UILabel().then {
        $0.text = "댓글"
        $0.textColor = .pointLight
        $0.font = .boldBody
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CommentHeaderCollectionReusableView {
    private func configure() {
        addSubview(commentLabel)
        commentLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
