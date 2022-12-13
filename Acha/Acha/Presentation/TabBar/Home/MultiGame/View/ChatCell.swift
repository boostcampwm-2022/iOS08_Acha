//
//  ChatCell.swift
//  Acha
//
//  Created by hong on 2022/12/08.
//

import UIKit
import SnapKit
import Then

final class ChatCell: UICollectionViewCell {
    static let identifier = String(describing: ChatCell.self)
    
    private lazy var textLabel = PaddingLabel(topInset: 10, bottomInset: 10, leftInset: 20, rightInset: 20).then {
        $0.font = .commentBody
        $0.textColor = .black
        $0.numberOfLines = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        addSubview(textLabel)
        textLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind(data: Chat) {
        textLabel.text = "\(data.nickName) : \(data.text)"
    }
}
