//
//  GameOverView.swift
//  Acha
//
//  Created by 조승기 on 2022/11/29.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

class GameOverView: UIView {
    // MARK: - UI properties
    private let gameOverLabel: UILabel = UILabel().then {
        $0.text = "게임 종료"
        $0.font = .largeTitle
        $0.textAlignment = .center
    }
    private let mapNameLabel: UILabel = UILabel().then {
        $0.font = .largeBody
        $0.textAlignment = .center
    }
    private let timeLabel: UILabel = UILabel().then {
        $0.text = "시간"
        $0.font = .largeTitle
        $0.textAlignment = .left
    }
    private let timeValueLabel: UILabel = UILabel().then {
        $0.font = .body
        $0.textAlignment = .center
    }
    private let distanceLabel: UILabel = UILabel().then {
        $0.text = "거리"
        $0.font = .largeTitle
        $0.textAlignment = .left
    }
    private let distanceValueLabel: UILabel = UILabel().then {
        $0.font = .body
        $0.textAlignment = .center
    }
    private let kcalLabel: UILabel = UILabel().then {
        $0.text = "칼로리"
        $0.font = .largeTitle
        $0.textAlignment = .left
    }
    private let kcalValueLabel: UILabel = UILabel().then {
        $0.font = .body
        $0.textAlignment = .center
    }
    private let rankBoardStackView: UIStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.spacing = 13
    }
    private let okButton: UIButton = UIButton().then {
        $0.setTitle("확인", for: .normal)
        $0.tintColor = .white
        $0.backgroundColor = .pointLight
        $0.layer.cornerRadius = 10
    }
    // MARK: - Properties
    var okButtonTap: ControlEvent<Void> {
        self.okButton.rx.tap
    }
    
    // MARK: - Lifecycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 0.6)
        self.layer.cornerRadius = 20
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func setupSubviews() {
        [gameOverLabel, mapNameLabel,
         timeLabel, timeValueLabel, distanceLabel, distanceValueLabel, kcalLabel, kcalValueLabel, okButton]
            .forEach {
                addSubview($0)
            }
        
        gameOverLabel.snp.makeConstraints {
            $0.top.equalTo(self).offset(35)
            $0.centerX.equalTo(self)
        }
        mapNameLabel.snp.makeConstraints {
            $0.top.equalTo(gameOverLabel.snp.bottom).offset(22)
            $0.centerX.equalTo(self)
        }
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(mapNameLabel.snp.bottom).offset(15)
            $0.leading.equalTo(self).inset(22)
        }
        timeValueLabel.snp.makeConstraints {
            $0.centerY.equalTo(timeLabel)
            $0.leading.equalTo(timeLabel.snp.trailing).offset(10)
        }
        distanceLabel.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(12)
            $0.leading.equalTo(timeLabel)
        }
        distanceValueLabel.snp.makeConstraints {
            $0.centerY.equalTo(distanceLabel)
            $0.leading.equalTo(distanceLabel.snp.trailing).offset(10)
        }
        kcalLabel.snp.makeConstraints {
            $0.top.equalTo(distanceLabel.snp.bottom).offset(12)
            $0.leading.equalTo(distanceLabel)
        }
        kcalValueLabel.snp.makeConstraints {
            $0.centerY.equalTo(kcalLabel)
            $0.leading.equalTo(kcalLabel.snp.trailing).offset(10)
        }
        okButton.snp.makeConstraints {
            $0.centerX.equalTo(self)
            $0.width.equalTo(102)
            $0.height.equalTo(63)
            $0.top.equalTo(kcalValueLabel).offset(60)
        }
    }
    
    func bind(
        mapName: String,
        time: String,
        distance: String,
        calorie: String
    ) {
        mapNameLabel.text = mapName
        timeValueLabel.text = time
        distanceValueLabel.text = distance
        kcalValueLabel.text = calorie
    }
}
