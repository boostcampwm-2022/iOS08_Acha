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
        $0.font = .smallTitle
        $0.textColor = .black
    }
    
    private lazy var dateLabel = UILabel().then {
        $0.font = .body
        $0.textColor = .gray
    }
    
    private lazy var optionButton = UIButton().then {
        $0.setImage(.ellipsisImage, for: .normal)
    }
    
    init() {
        super.init(frame: .zero)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PostHeaderCollectionReusableView {
    private func layout() {
        addViews()
        addConstraints()
        self.layer.addBorder(directions: [.bottom, .top], color: .gray, width: 1)
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
            $0.width.equalTo(80)
        }
        
        optionButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
    }
}
