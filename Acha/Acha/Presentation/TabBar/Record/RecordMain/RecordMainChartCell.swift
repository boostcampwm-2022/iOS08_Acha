//
//  RecordChartCell.swift
//  Acha
//
//  Created by 배남석 on 2022/11/15.
//

import UIKit

class RecordMainChartCell: UICollectionViewCell {
    enum Week: String, CaseIterable {
        case sunday = "일"
        case monday = "월"
        case tuesday = "화"
        case wednesday = "수"
        case thursday = "목"
        case friday = "금"
        case saturday = "토"
    }
    
    // MARK: - UI properties
    private lazy var largeStackView = UIStackView().then {
        $0.distribution = .fill
        $0.axis = .horizontal
        $0.backgroundColor = .white
    }
    
    private lazy var chartsBackgroundStackView = UIStackView().then {
        $0.backgroundColor = .lightGray
        $0.distribution = .fillEqually
        $0.spacing = 1
        $0.axis = .vertical
    }
    
    private lazy var distanceStackView = UIStackView().then {
        $0.backgroundColor = .white
        $0.distribution = .equalSpacing
        $0.spacing = -20
        $0.axis = .vertical
    }
    
    private let graphLayer = CAShapeLayer().then {
        $0.fillColor = nil
        $0.strokeColor = UIColor.pointLight.cgColor
        $0.lineWidth = 2
    }
    private lazy var firstDistanceLabel = UILabel()
    private lazy var secondDistanceLabel = UILabel()
    private lazy var thirdDistanceLabel = UILabel()
    private lazy var fourthDistanceLabel = UILabel()
    private lazy var fifthDistanceLabel = UILabel()
    private lazy var sixthDistanceLabel = UILabel()
    private lazy var seventhDistanceLabel = UILabel()
    
    private lazy var firstLabel = UILabel()
    private lazy var secondLabel = UILabel()
    private lazy var thirdLabel = UILabel()
    private lazy var fourthLabel = UILabel()
    private lazy var fifthLabel = UILabel()
    private lazy var sixthLabel = UILabel()
    private lazy var seventhLabel = UILabel()
    
    private lazy var labelList: [UILabel] = [firstLabel, secondLabel, thirdLabel, fourthLabel,
                                             fifthLabel, sixthLabel, seventhLabel]
    private lazy var distanceLabelList: [UILabel] = [firstDistanceLabel, secondDistanceLabel,
                                                     thirdDistanceLabel, fourthDistanceLabel,
                                                     fifthDistanceLabel, sixthDistanceLabel,
                                                     seventhDistanceLabel]
    
    // MARK: - Properties
    static let identifier = "RecordChartCell"
    
    // MARK: - Lifecycles
    override init(frame: CGRect) {
        print(#function)
        super.init(frame: frame)
        setUpSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func setUpSubviews() {
        contentView.addSubview(largeStackView)
        largeStackView.addArrangedSubview(chartsBackgroundStackView)
        largeStackView.addArrangedSubview(distanceStackView)
        
        (1...8).forEach { _ in
            let backgrounView = UIView().then {
                $0.backgroundColor = .white
            }
            chartsBackgroundStackView.addArrangedSubview(backgrounView)
        }
        
        let stackView = UIStackView().then {
            $0.axis = .horizontal
            $0.distribution = .fillEqually
            $0.backgroundColor = .white
        }
        
        labelList.forEach {
            stackView.addArrangedSubview($0)
        }
        chartsBackgroundStackView.addArrangedSubview(stackView)
        
        distanceLabelList.forEach { label in
            distanceStackView.addArrangedSubview(label)
        }
        
        let lastDistanceLabel = UILabel().then { label in
            label.font = .smallTitle
            label.textColor = .pointLight
            label.textAlignment = .center
            label.text = "0"
        }
        distanceStackView.addArrangedSubview(lastDistanceLabel)
        
        configureUI()
    }
    
    private func configureUI() {
        contentView.backgroundColor = .gray
        
        largeStackView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
  
        distanceStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(35)
            $0.bottom.equalToSuperview().offset(-35)
            $0.width.equalTo(50)
        }
        
        chartsBackgroundStackView.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
        }
        
        labelList.forEach { label in
            label.font = .smallTitle
            label.textColor = .pointLight
            label.textAlignment = .center
        }
        
        distanceLabelList.forEach { label in
            label.font = .smallTitle
            label.textColor = .pointLight
            label.textAlignment = .center
        }
    }
    
    func bind(recordViewChartDataArray: [RecordViewChartData]) {
        let days = Week.allCases
        
        let distances = recordViewChartDataArray.map { $0.distance }
        
        guard let max = distances.max() else { return }
        
        let spacing = max / 8
        
        var current = 0
        
        distanceLabelList.reversed().forEach {
            current += spacing
            $0.text = "\(current)"
        }
        
        recordViewChartDataArray.enumerated().forEach { index, element in
            labelList[index].text = days[element.number - 1].rawValue
        }
    }
}
