//
//  CommunityDetailCommentHeaderView.swift
//  Acha
//
//  Created by 배남석 on 2022/12/05.
//

import UIKit

final class CommunityDetailCommentHeaderView: UICollectionReusableView {
    // MARK: - UI properties
    private lazy var titleLabel: UILabel = UILabel().then {
        $0.text = "댓글"
        $0.font = .largeTitle
        $0.textColor = .pointLight
    }
    
    // MARK: - Properties
    static let identifier = "CommunityDetailCommentHeaderView"
    
    // MARK: - Lifecycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func setupViews() {
        addSubview(titleLabel)
    }
    
    private func configureUI() {
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalToSuperview().offset(20)
        }
    }
}
