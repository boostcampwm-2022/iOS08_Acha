//
//  GameRoomCollectionViewCell.swift
//  Acha
//
//  Created by hong on 2022/11/24.
//

import UIKit
import Then
import SnapKit

final class GameRoomCell: UICollectionViewCell {
    static let identifier = "gameRoomCollectionViewCell"
    private lazy var nameLabel = PaddingLabel(
        topInset: 0,
        bottomInset: 0,
        leftInset: 12,
        rightInset: 12
    ).then {
        $0.numberOfLines = 0
        $0.font = .commentBody
        $0.textColor = .pointDark
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = ""
    }
}

extension GameRoomCell {
    func layout() {
        addViews()
        addConstratins()
    }
    
    func addViews() {
        addSubview(nameLabel)
    }
    
    func addConstratins() {
        nameLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension GameRoomCell {
    func bind(data: RoomUser) {
        nameLabel.text = data.nickName
    }
}
