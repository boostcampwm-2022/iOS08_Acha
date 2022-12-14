//
//  CommunityDetailCommentCell.swift
//  Acha
//
//  Created by 배남석 on 2022/12/05.
//

import UIKit

final class CommunityDetailCommentCell: UICollectionViewCell {
    // MARK: - UI properties
    private lazy var largeStackView: UIStackView = UIStackView().then {
        $0.backgroundColor = .pointLight
        $0.distribution = .fill
        $0.axis = .vertical
        $0.layer.borderColor = UIColor.pointLight.cgColor
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 10
    }
    
    private lazy var titleStackView = UIStackView().then {
        $0.distribution = .fill
        $0.axis = .horizontal
        $0.isLayoutMarginsRelativeArrangement = true
        $0.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    private lazy var contextStackView = UIStackView().then {
        $0.backgroundColor = .white
        $0.distribution = .fill
        $0.axis = .vertical
        $0.spacing = 10
        $0.isLayoutMarginsRelativeArrangement = true
        $0.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
    }
    
    private lazy var nickNameLabel: UILabel = UILabel().then {
        $0.font = .title
        $0.textColor = .white
        $0.numberOfLines = 0
    }
    
    private lazy var createDateLabel: UILabel = UILabel().then {
        $0.font = .commentBody
        $0.textColor = .white
        $0.textAlignment = .right
        $0.numberOfLines = 0
    }
    
    private lazy var commentTextView: UITextView = UITextView().then {
        $0.backgroundColor = .white
        $0.font = .postBody
        $0.textColor = .black
        $0.isSelectable = false
        $0.isScrollEnabled = false
    }
    
    // MARK: - Properties
    static let identifier = "CommunityDetailCommentCell"
    private var id: Int = -1
    private var postID: Int = -1
    
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
        contentView.addSubview(largeStackView)
        largeStackView.addArrangedSubview(titleStackView)
        largeStackView.addArrangedSubview(contextStackView)
        titleStackView.addArrangedSubview(nickNameLabel)
        titleStackView.addArrangedSubview(createDateLabel)
        contextStackView.addArrangedSubview(commentTextView)
    }
    
    private func configureUI() {
        largeStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }
        
        contextStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }
        
        commentTextView.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(50).priority(500)
        }
        
        createDateLabel.snp.makeConstraints {
            $0.width.equalTo(100)
        }
    }
    
    func bind(comment: Comment) {
        id = comment.id
        postID = comment.postId
        nickNameLabel.text = comment.nickName
        createDateLabel.text = comment.createdAt.convertToStringFormat(format: "YYYY-MM-dd")
        commentTextView.text = comment.text
    }
}
