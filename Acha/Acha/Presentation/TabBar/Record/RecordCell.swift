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
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.textColor = UIColor(named: "PointLightColor")
        $0.sizeToFit()
    }
    
    private lazy var timeLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .bold)
        $0.textColor = UIColor(named: "PointLightColor")
        $0.sizeToFit()
    }
    
    private lazy var modeLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .bold)
        $0.textColor = UIColor(named: "PointLightColor")
        $0.sizeToFit()
    }
    
    private lazy var distanceLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .bold)
        $0.textColor = UIColor(named: "PointLightColor")
        $0.sizeToFit()
    }
    
    private lazy var kcalLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .bold)
        $0.textColor = UIColor(named: "PointLightColor")
        $0.sizeToFit()
    }
    
    // MARK: - Properties
    static let identifier = "RecordCell"
    
    // MARK: - Lifecycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func setupSubviews() {
        [imageView, mapNameLabel, timeLabel, modeLabel, distanceLabel, kcalLabel].forEach {
            contentView.addSubview($0)
        }
        
        configureUI()
    }
    
    private func configureUI() {
        contentView.layer.cornerRadius = 15
        contentView.layer.borderColor = UIColor(named: "PointLightColor")?.cgColor
        contentView.layer.borderWidth = 3
        
        imageView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview().inset(15)
            $0.width.equalTo(70)
        }
        
        mapNameLabel.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(15)
            $0.leading.equalTo(imageView.snp.trailing).offset(15)
            $0.height.equalTo(30)
        }
        
        timeLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(15)
            $0.top.equalTo(mapNameLabel.snp.bottom)
            $0.width.equalTo(100)
            $0.height.equalTo(20)
        }
        
        modeLabel.snp.makeConstraints {
            $0.leading.equalTo(timeLabel.snp.trailing).inset(5)
            $0.top.equalTo(mapNameLabel.snp.bottom)
            $0.width.equalTo(100)
            $0.height.equalTo(20)
        }
        
        distanceLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(15)
            $0.top.equalTo(timeLabel.snp.bottom)
            $0.height.equalTo(20)
            $0.width.equalTo(100)
        }
        
        kcalLabel.snp.makeConstraints {
            $0.leading.equalTo(distanceLabel.snp.trailing).inset(5)
            $0.top.equalTo(modeLabel.snp.bottom)
            $0.height.equalTo(20)
            $0.width.equalTo(100)
        }
    }
    
    func bind(record: Record) {
        mapNameLabel.text = record.mapName
        timeLabel.text = record.time
        modeLabel.text = record.mode
        distanceLabel.text = record.distance
        kcalLabel.text = record.kcal
    }
}
