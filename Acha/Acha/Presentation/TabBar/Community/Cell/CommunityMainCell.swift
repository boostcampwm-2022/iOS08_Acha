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
import RxRelay

final class CommunityMainCell: UICollectionViewCell {
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
        $0.spacing = 5
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
    
    private lazy var postTextView: UITextView = UITextView().then {
        $0.backgroundColor = .white
        $0.font = .postBody
        $0.textColor = .black
        $0.isEditable = false
        $0.isScrollEnabled = false
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(textViewTapped)))
    }
    
    private lazy var postImageView: UIImageView = UIImageView().then {
        $0.backgroundColor = .white
        $0.contentMode = .scaleAspectFill
        $0.image = nil
        $0.isHidden = true
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nickNameLabel.text = ""
        createDateLabel.text = ""
        postTextView.text = ""
        postImageView.isHidden = true
        commentCountLabel.text = "0"
    }
    
    // MARK: - Properties
    var id: Int = -1
    var textViewTapEvent: PublishRelay<Int>?
    
    // MARK: - Helper
    private func setupViews() {
        contentView.addSubview(largeStackView)
        largeStackView.addArrangedSubview(titleStackView)
        largeStackView.addArrangedSubview(contextStackView)
        titleStackView.addArrangedSubview(nickNameLabel)
        titleStackView.addArrangedSubview(createDateLabel)
        contextStackView.addArrangedSubview(postTextView)
        contextStackView.addArrangedSubview(postImageView)
        contextStackView.addArrangedSubview(commentInfoView)
        commentInfoView.addSubview(commentImageView)
        commentInfoView.addSubview(commentCountLabel)
    }
    
    private func configureUI() {
        largeStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }
        contextStackView.snp.makeConstraints {
            $0.trailing.leading.equalToSuperview()
        }
        
        createDateLabel.snp.makeConstraints {
            $0.width.equalTo(100)
        }

        postTextView.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(30).priority(750)
        }
        
//        postImageView.snp.makeConstraints {
//            $0.height.equalTo
//        }

        commentInfoView.snp.makeConstraints {
            $0.height.equalTo(50).priority(500)
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
        textViewTapEvent = PublishRelay<Int>()
        id = post.id
        nickNameLabel.text = post.nickName
        createDateLabel.text = post.createdAt.convertToStringFormat(format: "YYYY-MM-dd")
        postTextView.text = post.text
        
        if let data = post.image {
            postImageView.isHidden = false
            postImageView.image = UIImage(data: data)?.resize(newWidth: contentView.frame.width - 20)
            
        } else {
            postImageView.isHidden = true
        }
        
        if let comments = post.comments {
            commentCountLabel.text = "\(comments.count)"
        } else {
            commentCountLabel.text = "0"
        }
    }
    
    @objc private func textViewTapped() {
        textViewTapEvent?.accept(id)
    }
}
