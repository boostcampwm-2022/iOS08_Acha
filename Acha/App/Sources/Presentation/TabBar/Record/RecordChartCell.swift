//
//  RecordChartCell.swift
//  Acha
//
//  Created by 배남석 on 2022/11/15.
//

import UIKit

enum Week: String, CaseIterable {
    case sunday = "일"
    case monday = "월"
    case tuesday = "화"
    case wednesday = "수"
    case thursday = "목"
    case friday = "금"
    case saturday = "토"
}

class RecordChartCell: UICollectionViewCell {
    // MARK: - UI properties
    private lazy var chartsBackgroundStackView = UIStackView().then {
        $0.distribution = .fillEqually
        $0.spacing = 1
        $0.axis = .vertical
    }
    
    private lazy var weekStackView = UIStackView().then {
        $0.distribution = .fillEqually
        $0.spacing = 10
        $0.axis = .horizontal
    }
    
    private lazy var firstView = UIView().then {
        $0.backgroundColor = .clear
    }
    private lazy var secondView = UIView().then {
        $0.backgroundColor = .clear
    }
    private lazy var thirdView = UIView().then {
        $0.backgroundColor = .clear
    }
    private lazy var fourthView = UIView().then {
        $0.backgroundColor = .clear
    }
    private lazy var fivethView = UIView().then {
        $0.backgroundColor = .clear
    }
    private lazy var sixthView = UIView().then {
        $0.backgroundColor = .clear
    }
    private lazy var seventhView = UIView().then {
        $0.backgroundColor = .clear
    }
    private lazy var firstLabel = UILabel().then {
        $0.font = .smallTitle
        $0.textColor = .pointLight
        $0.textAlignment = .center
    }
    private lazy var secondLabel = UILabel().then {
        $0.font = .smallTitle
        $0.textColor = .pointLight
        $0.textAlignment = .center
    }
    private lazy var thirdLabel = UILabel().then {
        $0.font = .smallTitle
        $0.textColor = .pointLight
        $0.textAlignment = .center
    }
    private lazy var fourthLabel = UILabel().then {
        $0.font = .smallTitle
        $0.textColor = .pointLight
        $0.textAlignment = .center
    }
    private lazy var fivethLabel = UILabel().then {
        $0.font = .smallTitle
        $0.textColor = .pointLight
        $0.textAlignment = .center
    }
    private lazy var sixthLabel = UILabel().then {
        $0.font = .smallTitle
        $0.textColor = .pointLight
        $0.textAlignment = .center
    }
    private lazy var seventhLabel = UILabel().then {
        $0.font = .smallTitle
        $0.textColor = .pointLight
        $0.textAlignment = .center
    }
    
    // MARK: - Properties
    static let identifier = "RecordChartCell"
    
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
        contentView.addSubview(chartsBackgroundStackView)
        contentView.addSubview(weekStackView)
        
        (1...9).forEach { _ in
            let backgrounView = UIView().then {
                $0.backgroundColor = .white
            }
            chartsBackgroundStackView.addArrangedSubview(backgrounView)
        }
        
        [firstView, secondView, thirdView, fourthView, fivethView, sixthView, seventhView]
            .enumerated()
            .forEach { (index, view) in
                
                let stackView = UIStackView().then {
                    $0.axis = .vertical
                }
                
                stackView.addArrangedSubview(view)
                let label = [firstLabel, secondLabel, thirdLabel, fourthLabel, fivethLabel, sixthLabel, seventhLabel][index]
                stackView.addArrangedSubview(label)
                
                weekStackView.addArrangedSubview(stackView)
        }
        
        configureUI()
    }
    
    private func configureUI() {
        contentView.backgroundColor = .gray
        
        chartsBackgroundStackView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        weekStackView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        [firstLabel, secondLabel, thirdLabel, fourthLabel, fivethLabel, sixthLabel, seventhLabel]
            .forEach { label in
                label.snp.makeConstraints {
                    $0.height.equalTo(45)
                }
            }
    }
    
    func bind(recordViewChartDataArray: [RecordViewChartData]) {
        let days = Week.allCases
        
        let maxDistance = recordViewChartDataArray.max { chartDataA, chartDataB in
            return chartDataA.distance < chartDataB.distance
        }.map { Double($0.distance) }
        
        guard let maxDistance else { return }
        
        let chartHeight = 368.0
        let heightPerMeter = chartHeight / maxDistance
        
        recordViewChartDataArray.enumerated().forEach { index, element in
            [firstLabel,
             secondLabel,
             thirdLabel,
             fourthLabel,
             fivethLabel,
             sixthLabel,
             seventhLabel][index].text = days[element.number - 1].rawValue
            [firstView, secondView, thirdView, fourthView, fivethView, sixthView, seventhView][index].subviews.forEach {
                $0.removeFromSuperview()
            }
            
            let customView = UIView().then {
                $0.backgroundColor = .pointLight
            }
            
            [firstView,
             secondView,
             thirdView,
             fourthView,
             fivethView,
             sixthView,
             seventhView][index].addSubview(customView)
            
            customView.snp.makeConstraints {
                $0.bottom.equalToSuperview()
                $0.leading.trailing.equalToSuperview().inset(10)
                $0.height.equalTo(heightPerMeter * Double(element.distance))
            }
        }
    }
}
