//
//  PostHeaderCollectionReusableView.swift
//  Acha
//
//  Created by hong on 2022/11/29.
//

import UIKit

final class PostHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "PostHeader"
    
    private lazy var nickNameLabel = UILabel().then {
        $0.font = .boldBody
        $0.textColor = .black
    }
    
    private lazy var dateLabel = UILabel().then {
        $0.font = .smallTitle
        $0.textColor = .gray
    }
    
    private lazy var optionButton = UIButton().then {
        $0.setImage(.ellipsisImage, for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(data: Post) {
        nickNameLabel.text = data.nickName
        dateLabel.text = data.createdAt.convertToStringFormat(format: "YYYY-mm-dd")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nickNameLabel.text = ""
        dateLabel.text = ""
    }
}

extension PostHeaderCollectionReusableView {
    private func layout() {
        addViews()
        addConstraints()
    }
    
    private func addViews() {
        addSubview(nickNameLabel)
        addSubview(dateLabel)
        addSubview(optionButton)
    }
    
    private func addConstraints() {
        nickNameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(100)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalTo(nickNameLabel.snp.trailing)
            $0.width.equalTo(150)
        }
        
        optionButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(100)
        }
    }
}
