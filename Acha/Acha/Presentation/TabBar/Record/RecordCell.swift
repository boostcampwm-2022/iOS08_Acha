//
//  RecordCell.swift
//  Acha
//
//  Created by 배남석 on 2022/11/15.
//

import UIKit

class RecordCell: UICollectionViewCell {
    // MARK: - UI properties
    private lazy var imageView = UIImageView().then {
        $0.image = UIImage(systemName: "house")
    }
    
    private lazy var mapNameLabel = UILabel().then {
        $0.font = .title
        $0.textColor = .pointLight
    }
    
    private lazy var timeLabel = UILabel().then {
        $0.font = .recordBody
        $0.textColor = .pointLight
    }
    
    private lazy var modeLabel = UILabel().then {
        $0.font = .recordBody
        $0.textColor = .pointLight
    }
    
    private lazy var distanceLabel = UILabel().then {
        $0.font = .recordBody
        $0.textColor = .pointLight
    }
    
    private lazy var kcalLabel = UILabel().then {
        $0.font = .recordBody
        $0.textColor = .pointLight
    }
    
    private lazy var winLabel = UILabel().then {
        $0.font = .title
        $0.textColor = .pointLight
    }
    
    // MARK: - Properties
    static let identifier = "RecordCell"
    
    // MARK: - Lifecycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func setUpSubviews() {
        [imageView, mapNameLabel, winLabel, timeLabel, modeLabel, distanceLabel, kcalLabel].forEach {
            contentView.addSubview($0)
        }
        
        configureUI()
    }
    
    private func configureUI() {
        contentView.layer.cornerRadius = 15
        contentView.layer.borderColor = UIColor.pointLight.cgColor
        contentView.layer.borderWidth = 3
        
        imageView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview().inset(15)
            $0.width.equalTo(70)
        }
        
        mapNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(15)
            $0.leading.equalTo(imageView.snp.trailing).offset(15)
            $0.height.equalTo(30)
        }
        
        winLabel.snp.makeConstraints {
            $0.centerY.equalTo(mapNameLabel)
            $0.leading.equalTo(mapNameLabel.snp.trailing).offset(5)
            $0.height.equalTo(30)
        }
        
        timeLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(15)
            $0.top.equalTo(mapNameLabel.snp.bottom)
            $0.width.equalTo(120)
            $0.height.equalTo(20)
        }
        
        modeLabel.snp.makeConstraints {
            $0.leading.equalTo(timeLabel.snp.trailing).inset(5)
            $0.top.equalTo(timeLabel)
            $0.width.height.equalTo(timeLabel)
        }
        
        distanceLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(15)
            $0.top.equalTo(timeLabel.snp.bottom)
            $0.width.height.equalTo(timeLabel)
        }
        
        kcalLabel.snp.makeConstraints {
            $0.leading.equalTo(distanceLabel.snp.trailing).inset(5)
            $0.top.equalTo(distanceLabel)
            $0.width.height.equalTo(timeLabel)
        }
    }
    
    func bind(mapName: String, recordViewRecord: Record) {
        imageView.image = UIImage(systemName: "house")
        if let isWin = recordViewRecord.isWin {
            winLabel.isHidden = false
            if isWin {
                winLabel.text = "승"
                winLabel.textColor = .red
            } else {
                winLabel.text = "패"
                winLabel.textColor = .blue
            }
        } else {
            winLabel.isHidden = true
        }
        mapNameLabel.text = mapName
        timeLabel.text = "시간: \(recordViewRecord.time.convertToDayHourMinueFormat())"
        modeLabel.text = recordViewRecord.isSingleMode == true ? "모드: 혼자 하기" : "모드: 같이 하기"
        distanceLabel.text = "거리: \(recordViewRecord.distance.convertToDecimal) m"
        kcalLabel.text = "칼로리: \(recordViewRecord.calorie.convertToDecimal) kcal"
    }
}
