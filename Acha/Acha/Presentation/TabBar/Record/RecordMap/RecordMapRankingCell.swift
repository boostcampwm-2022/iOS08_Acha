//
//  RecordMapRankingCell.swift
//  Acha
//
//  Created by 배남석 on 2022/11/22.
//

import UIKit

class RecordMapRankingCell: UICollectionViewCell {
    private lazy var rankingLabel = UILabel().then {
           $0.textColor = .pointLight
           $0.font = .largeBody
           $0.textAlignment = .center
       }
       
       private lazy var pinImageView = UIImageView().then {
           $0.contentMode = .scaleAspectFit
           $0.clipsToBounds = true
       }
       
       private lazy var idLabel = UILabel().then {
           $0.textColor = .pointLight
           $0.font = .title
       }
       
       private lazy var timeLabel = UILabel().then {
           $0.textColor = .gray
           $0.font = .subBody
       }
       
       static let identifier: String = "RecordMapRankingCell"
       
       override init(frame: CGRect) {
           super.init(frame: frame)
           configureUI()
       }
       
       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }

       func configureUI() {
           contentView.layer.borderColor = UIColor.pointLight.cgColor
           contentView.layer.borderWidth = 2
           contentView.layer.cornerRadius = 15
           
           [rankingLabel, pinImageView, idLabel, timeLabel].forEach {
               contentView.addSubview($0)
           }
           
           rankingLabel.snp.makeConstraints {
               $0.top.bottom.equalToSuperview()
               $0.leading.equalTo(20)
               $0.width.equalTo(30)
           }
           
           pinImageView.snp.makeConstraints {
               $0.leading.equalTo(rankingLabel.snp.trailing)
               $0.top.bottom.equalToSuperview()
               $0.width.equalTo(50)
           }
           
           idLabel.snp.makeConstraints {
               $0.leading.equalTo(pinImageView.snp.trailing).offset(15)
               $0.trailing.equalToSuperview().offset(-15)
               $0.centerY.equalToSuperview().offset(-5)
               $0.height.equalTo(30)
           }
           
           timeLabel.snp.makeConstraints {
               $0.leading.equalTo(idLabel)
               $0.top.equalTo(idLabel.snp.bottom)
               $0.trailing.equalTo(idLabel)
           }
       }
       
       func bind(ranking: Int, record: RecordViewRecord) {
           rankingLabel.text = String(ranking)
           idLabel.text = record.userID
           timeLabel.text = record.time.convertToDayHourMinueFormat()
           pinImageView.image = UIImage(named: "penguin")
       }
}
