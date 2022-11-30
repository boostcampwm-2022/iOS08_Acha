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
        $0.axis = .vertical
        $0.distribution = .fill
        $0.spacing = 1
    }
    
    private lazy var titleStackView = UIStackView().then {
        $0.backgroundColor = .white
        $0.distribution = .fill
        $0.axis = .horizontal
        $0.spacing = 5
    }
    
    private lazy var contenxtStackView = UIStackView().then {
        $0.distribution = .fill
        $0.axis = .vertical
    }

    private lazy var nickNameLabel: UILabel = UILabel().then {
        $0.font = .title
        $0.textAlignment = .center
    }
    
    private lazy var createDateLabel: UILabel = UILabel().then {
        $0.font = .commentBody
        $0.textColor = .lightGray
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
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helper
    private func layout() {
        setupViews()
        configureUI()
    }
    
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
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalToSuperview().inset(5)
        }
        
        titleStackView.snp.makeConstraints {
            $0.height.equalTo(70)
            $0.leading.trailing.equalToSuperview()
        }
        contenxtStackView.snp.makeConstraints {
            $0.trailing.leading.equalToSuperview()
        }
        
        nickNameLabel.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.width.lessThanOrEqualTo(100)
        }
        
        createDateLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
        }

        postTextLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.lessThanOrEqualTo(100)
        }
        
        postImageView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }

        commentInfoView.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.leading.trailing.equalToSuperview()
        }

        commentImageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(10)
            $0.width.equalTo(30)
        }

        commentCountLabel.snp.makeConstraints {
            $0.leading.equalTo(commentImageView.snp.trailing).offset(10)
            $0.width.greaterThanOrEqualTo(30)
            $0.top.bottom.equalToSuperview().inset(10)
        }
    }
    
    func bind(postData: Post) {
        nickNameLabel.text = postData.nickName
        createDateLabel.text = postData.createdAt.convertToStringFormat(format: "YYYY-MM-dd")
        postTextLabel.text = postData.text
        // 이미지 ???
        if postData.image != nil {
            postImageView.image = .checkmark
        } else {
            postImageView.isHidden = true
        }
        commentCountLabel.text = "\(postData.commentCount)"
    }
}
