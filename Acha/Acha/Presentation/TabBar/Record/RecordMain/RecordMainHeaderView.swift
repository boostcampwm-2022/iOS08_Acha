//
//  RecordHeaderView.swift
//  Acha
//
//  Created by 배남석 on 2022/11/15.
//

import UIKit
import RxSwift
import RxRelay

class RecordMainHeaderView: UICollectionReusableView {
    // MARK: - UI properties
    private lazy var dateLabel = UILabel().then {
        $0.font = .largeTitle
        $0.textColor = .pointLight
        $0.textAlignment = .center
    }
    
    private lazy var distanceLabel = UILabel().then {
        $0.font = .smallTitle
        $0.textColor = .pointLight
        $0.textAlignment = .center
    }
    
    private lazy var kcalLabel = UILabel().then {
        $0.font = .smallTitle
        $0.textColor = .pointLight
        $0.textAlignment = .center
    }
    
    // MARK: - Properties
    static let identifier = "RecordHeaderView"
    var bindEvent = PublishRelay<String>()
    
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
        [dateLabel, distanceLabel, kcalLabel].forEach {
            addSubview($0)
        }
        
        configureUI()
    }
    
    private func configureUI() {
        dateLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        distanceLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(25)
        }
        
        kcalLabel.snp.makeConstraints {
            $0.top.equalTo(distanceLabel.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func bind(headerRecord: RecordViewHeaderRecord) {
        dateLabel.text = headerRecord.date
        distanceLabel.text = "누적 거리: \(headerRecord.distance.convertToDecimal) m"
        kcalLabel.text = "누적 칼로리: \(headerRecord.kcal.convertToDecimal) kcal"
    }
}
