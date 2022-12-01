//
//  CommunityCollectionViewCell.swift
//  Acha
//
//  Created by hong on 2022/11/28.
//

import UIKit
import Then
import SnapKit

final class CommunityCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "CommunityCollectinoViewCell"
    
    private lazy var titleStackView = UIStackView().then {
        $0.spacing = 10
        $0.distribution = .equalSpacing
        $0.axis = .horizontal
    }
    
    private lazy var contenxtStackView = UIStackView().then {
        $0.spacing = 10
        $0.distribution = .equalSpacing
        $0.axis = .vertical
    }

    private lazy var nickNameLabel: UILabel = UILabel().then {
        $0.font = .title
        $0.textColor = .black
        $0.textAlignment = .center
    }
    
    private lazy var createDateLabel: UILabel = UILabel().then {
        $0.font = .commentBody
        $0.textColor = .gray
        $0.textAlignment = .center
    }
    
    private lazy var editButton: UIButton = UIButton().then {
        $0.setImage(UIImage(systemName: "ellipsis"), for: .normal)
    }
    
    private lazy var postTextLabel: UILabel = UILabel().then {
        $0.font = .postBody
        $0.textColor = .black
        $0.numberOfLines = 3
    }
    
    private lazy var postImageView: UIImageView = UIImageView().then {
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
        $0.textColor = .black
        
    }
    
    func bindData(data: Post) {
        nickNameLabel.text = data.nickName
        createDateLabel.text = data.createdAt.convertToStringFormat(format: "YYYY-MM-dd")
        postTextLabel.text = data.text
        // 이미지 ???
//        postImageView.image = .checkmark
        commentCountLabel.text = "\(data.commentCount)"
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        layout()
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nickNameLabel.text = ""
        createDateLabel.text = ""
        postTextLabel.text = ""
        postImageView.image = nil
        commentCountLabel.text = ""
    }
}

extension CommunityCollectionViewCell {
    private func layout() {
        addViews()
        addConstraints()
    }
    
    private func addViews() {
        addSubview(titleStackView)
        addSubview(contenxtStackView)
        titleStackView.addArrangedSubview(nickNameLabel)
        titleStackView.addArrangedSubview(createDateLabel)
        titleStackView.addArrangedSubview(editButton)
        contenxtStackView.addArrangedSubview(postTextLabel)
        contenxtStackView.addArrangedSubview(postImageView)
        contenxtStackView.addArrangedSubview(commentInfoView)
        commentInfoView.addSubview(commentImageView)
        commentInfoView.addSubview(commentCountLabel)
    }
    
    private func addConstraints() {
        titleStackView.snp.makeConstraints {
            $0.height.equalTo(100)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        contenxtStackView.snp.makeConstraints {
            $0.top.equalTo(titleStackView.snp.bottom)
            $0.trailing.leading.equalToSuperview().inset(20)
            $0.height.equalTo(200)
        }

        postImageView.snp.makeConstraints {
            $0.top.equalTo(postTextLabel.snp.bottom).inset(-10)
            $0.height.equalTo(50)
        }

        commentInfoView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }

        commentImageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview().inset(10)
            $0.height.width.equalTo(30)
        }

        commentCountLabel.snp.makeConstraints {
            $0.leading.equalTo(commentImageView).inset(40)
            $0.top.width.height.equalTo(commentImageView)
        }
    }
}
