//
//  CommentCollectionViewCell.swift
//  Acha
//
//  Created by hong on 2022/11/29.
//

import UIKit

final class CommentCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "CommentCollectionViewCell"

    private lazy var nickNameLabel = UILabel().then {
        $0.font = .boldBody
        $0.textAlignment = .center
        $0.textColor = .black
    }
    
    private lazy var timeLabel = UILabel().then {
        $0.font = .smallTitle
        $0.textColor = .black
    }
    
    private lazy var contextLabel = UILabel().then {
        $0.font = .body
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(data: Comment) {
        nickNameLabel.text = data.nickName
        timeLabel.text = data.createdAt.convertToStringFormat(format: "YYYY-mm-dd")
        contextLabel.text = data.text
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nickNameLabel.text = ""
        timeLabel.text = ""
        contextLabel.text = ""
    }
    
}

extension CommentCollectionViewCell {
    private func layout() {
        addViews()
        addConstraints()
    }
    
    private func addViews() {
        addSubview(nickNameLabel)
        addSubview(timeLabel)
        addSubview(contextLabel)
    }
    
    private func addConstraints() {
        nickNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(7)
            $0.width.equalTo(100)
            $0.height.equalTo(50)
        }
        
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(nickNameLabel)
            $0.leading.equalTo(nickNameLabel.snp.trailing).inset(-20)
            $0.height.equalTo(50)
            $0.width.equalTo(150)
        }
        
        contextLabel.snp.makeConstraints {
            $0.top.equalTo(nickNameLabel.snp.bottom).inset(10)
            $0.leading.equalTo(nickNameLabel)
            $0.trailing.bottom.equalToSuperview()
        }
    }
}
