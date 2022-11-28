//
//  CommunityCollectionViewCell.swift
//  Acha
//
//  Created by hong on 2022/11/28.
//

import UIKit
import Then
import SnapKit

class CommunityCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "CommunityCollectinoViewCell"
    
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
    
    private lazy var postStackView: UIStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
        $0.distribution = .equalSpacing
        $0.backgroundColor = .white
    }

    private lazy var postTextLabel: UILabel = UILabel().then {
        $0.font = .postBody
        $0.textColor = .black
        $0.numberOfLines = 3
    }
    
    private lazy var postImageView: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    private lazy var commentInfoView: UIView = UIView().then {
        $0.backgroundColor = .pointDark
    }

    private lazy var commentImageView: UIImageView = UIImageView().then {
        $0.image = .commentImage
    }
    
    private lazy var commentCountLabel: UILabel = UILabel().then {
        $0.font = .commentBody
        $0.textColor = .white
        
    }
    
    func bindData(data: Post) {
        nickNameLabel.text = data.nickName
        createDateLabel.text = data.createdAt.convertToStringFormat(format: "YYYY-MM-dd")
        postTextLabel.text = data.text
        // TODO: - 이미지 가져올 지 안 가져올 지 선택해야 함
        postImageView.image = .checkmark
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
        addSubview(nickNameLabel)
        addSubview(createDateLabel)
        addSubview(editButton)
        addSubview(postStackView)
        postStackView.addArrangedSubview(postTextLabel)
        postStackView.addArrangedSubview(postImageView)
        postStackView.addArrangedSubview(commentInfoView)
        commentInfoView.addSubview(commentImageView)
        commentInfoView.addSubview(commentCountLabel)
    }
    
    private func addConstraints() {
        nickNameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview()
            $0.width.height.equalTo(40)
        }
        
        createDateLabel.snp.makeConstraints {
            $0.top.height.equalTo(nickNameLabel)
            $0.leading.equalTo(nickNameLabel).inset(60)
            $0.width.equalTo(100)
        }
        
        editButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.height.equalTo(nickNameLabel)
            $0.width.equalTo(50)
        }
        
        postStackView.snp.makeConstraints {
            $0.top.equalTo(nickNameLabel.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        postImageView.snp.makeConstraints {
            $0.height.equalTo(postStackView.snp.width)
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
