//
//  GameRankCollectionViewCell.swift
//  Acha
//
//  Created by hong on 2022/12/07.
//

import UIKit
import Then
import SnapKit

final class GameRankCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: GameRankCollectionViewCell.self)
    private let rankingLabel = PaddingLabel(topInset: 10, bottomInset: 10, leftInset: 10, rightInset: 10).then {
        $0.font = .smallTitle
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        addSubview(rankingLabel)
        rankingLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        rankingLabel.text = ""
    }
    
    func bind(data: MultiGamePlayerData, rank: Int) {
        let nickName = data.nickName.stringLimit(6)
        rankingLabel.text = "\(rank) : \(nickName) \(data.point) 점"
    }
    
}
