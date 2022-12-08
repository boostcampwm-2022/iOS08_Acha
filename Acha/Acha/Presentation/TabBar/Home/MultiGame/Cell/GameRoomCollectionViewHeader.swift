//
//  GameRoomCollectionViewHeader.swift
//  Acha
//
//  Created by hong on 2022/11/24.
//

import UIKit
import SnapKit
import Then

final class GameRoomCollectionViewHeader: UICollectionReusableView {
    static let identifier = "GameRoomCollectionViewHeader"
    private let headerLabel: PaddingLabel = PaddingLabel(
        topInset: 0,
        bottomInset: 0,
        leftInset: 10,
        rightInset: 0
    ).then {
        $0.font = .title
        $0.textColor = .white
        $0.textAlignment = .left
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .pointDark
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        headerLabel.text = ""
    }
}

extension GameRoomCollectionViewHeader {
    private func layout() {
        addViews()
        addConstraints()
    }
    
    private func addViews() {
        addSubview(headerLabel)
    }
    
    private func addConstraints() {
        headerLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind(playerNumber: Int) {
        headerLabel.text = "플레이어 \(playerNumber) 명"
    }
}
