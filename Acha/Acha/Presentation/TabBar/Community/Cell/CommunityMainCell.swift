//
//  CommunityCollectionViewCell.swift
//  Acha
//
//  Created by hong on 2022/11/28.
//

import UIKit
import Then
import SnapKit
import RxSwift

class CommunityMainCell: UICollectionViewCell {
    // MARK: - UI properties
    static let identifier = "CommunityMainCell"
    
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
    
    private lazy var contenxtStackView = UIStackView().then {
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
    
    private lazy var postTextLabel: UILabel = UILabel().then {
        $0.backgroundColor = .white
        $0.font = .postBody
        $0.numberOfLines = 3
    }
    
    private lazy var postImageView: UIImageView = UIImageView().then {
        $0.backgroundColor = .white
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var commentInfoView: UIView = UIView().then {
        $0.backgroundColor = .white
    }

    private lazy var commentImageView: UIImageView = UIImageView().then {
        $0.image = .commentImage
    }
    
    private lazy var commentCountLabel: UILabel = UILabel().then {
        $0.font = .commentBody
        $0.textAlignment = .center
    }
    
    // MARK: - Lifecycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        configureUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postImageView.image = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    private var id: Int = -1
    
    // MARK: - Helper
    
    private func setupViews() {
        contentView.addSubview(largeStackView)
        largeStackView.addArrangedSubview(titleStackView)
        largeStackView.addArrangedSubview(contenxtStackView)
        titleStackView.addArrangedSubview(nickNameLabel)
        titleStackView.addArrangedSubview(createDateLabel)
        contenxtStackView.addArrangedSubview(postTextLabel)
        contenxtStackView.addArrangedSubview(postImageView)
        contenxtStackView.addArrangedSubview(commentInfoView)
        commentInfoView.addSubview(commentImageView)
        commentInfoView.addSubview(commentCountLabel)
    }
    
    private func configureUI() {
        largeStackView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        titleStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }
        contenxtStackView.snp.makeConstraints {
            $0.trailing.leading.equalToSuperview()
        }

        createDateLabel.snp.makeConstraints {
            $0.width.equalTo(100)
        }

        postTextLabel.snp.makeConstraints {
            $0.height.lessThanOrEqualTo(100)
        }
        
        postImageView.snp.makeConstraints {
            $0.height.equalTo(300)
        }

        commentInfoView.snp.makeConstraints {
            $0.height.equalTo(50)
        }

        commentImageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(15)
            $0.width.equalTo(20)
        }

        commentCountLabel.snp.makeConstraints {
            $0.leading.equalTo(commentImageView.snp.trailing).offset(5)
            $0.width.lessThanOrEqualTo(50)
            $0.top.bottom.equalToSuperview().inset(10)
        }
    }
    
    func bind(post: Post) {
        id = post.id
        nickNameLabel.text = post.nickName
        createDateLabel.text = post.createdAt.convertToStringFormat(format: "YYYY-MM-dd")
        postTextLabel.text = post.text
        // 이미지 ???
        if post.image != nil {
            postImageView.image = .checkmark
        } else {
            postImageView.isHidden = true
        }
        
        if let comments = post.comments {
            commentCountLabel.text = "\(comments.count)"
        } else {
            commentCountLabel.text = "0"
        }
    }
    
    func getId() -> Int {
        return id
    }
}
