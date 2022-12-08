//
//  CommunityDetailPostCell.swift
//  Acha
//
//  Created by 배남석 on 2022/12/05.
//

import UIKit
import RxSwift
import RxRelay

final class CommunityDetailPostCell: UICollectionViewCell {
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
        $0.spacing = 10
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
    
    private lazy var ellipsisButton: UIButton = UIButton().then {
        $0.setImage(.ellipsisImage, for: .normal)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 30)
        $0.setPreferredSymbolConfiguration(imageConfig, forImageIn: .normal)
    }
    
    private lazy var postTextView: UITextView = UITextView().then {
        $0.backgroundColor = .white
        $0.font = .postBody
        $0.textColor = .black
        $0.isSelectable = false
    }
    
    private lazy var postImageView: UIImageView = UIImageView().then {
        $0.backgroundColor = .white
        $0.contentMode = .scaleAspectFit
        $0.image = nil
        $0.isHidden = true
    }
    
    // MARK: - Properties
    static let identifier = "CommunityDetailPostCell"
    var modifyButtonTapEvent = PublishRelay<Void>()
    var deleteButtonTapEvent = PublishRelay<Void>()
    
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
        largeStackView.addArrangedSubview(contenxtStackView)
        titleStackView.addArrangedSubview(nickNameLabel)
        titleStackView.addArrangedSubview(createDateLabel)
        titleStackView.addArrangedSubview(ellipsisButton)
        contenxtStackView.addArrangedSubview(postTextView)
        contenxtStackView.addArrangedSubview(postImageView)
    }
    
    private func configureUI() {
        largeStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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
        
        ellipsisButton.snp.makeConstraints {
            $0.width.equalTo(30)
        }

        postTextView.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(60)
        }
        
        postImageView.snp.makeConstraints {
            $0.height.equalTo(300).priority(750)
        }
        
        ellipsisButtonSetting()
    }
    
    private func ellipsisButtonSetting() {
        let menuItems: [UIAction] =
        [
            UIAction(title: "수정", handler: { [weak self] _ in
                guard let self else { return }
                print("수정")
                self.modifyButtonTapEvent.accept(())
            }),
            UIAction(title: "삭제", handler: { [weak self] _ in
                guard let self else { return }
                self.deleteButtonTapEvent.accept(())
            })
        ]
        let menu = UIMenu(title: "", children: menuItems)
        ellipsisButton.menu = menu
        ellipsisButton.showsMenuAsPrimaryAction = true
    }
    
    func bind(post: Post) {
        nickNameLabel.text = post.nickName
        createDateLabel.text = post.createdAt.convertToStringFormat(format: "YYYY-MM-dd")
        postTextView.text = post.text

        if let image = post.image {
            self.postImageView.isHidden = false
            let service = DefaultFirebaseStorageNetworkService()
            service.download(urlString: image) { data in
                guard let data else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.postImageView.image = UIImage(data: data)
                }
            }
        } else {
            postImageView.isHidden = true
        }
    }
}
