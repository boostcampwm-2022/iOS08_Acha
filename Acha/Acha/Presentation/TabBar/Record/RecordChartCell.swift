//
//  RecordChartCell.swift
//  Acha
//
//  Created by 배남석 on 2022/11/15.
//

import UIKit

enum Week: String, CaseIterable {
    case monday = "월"
    case tuesdayView = "화"
    case wednesdayView = "수"
    case thursdayView = "목"
    case fridayView = "금"
    case saturdayView = "토"
    case sundayView = "일"
}

class RecordChartCell: UICollectionViewCell {
    // MARK: - UI properties
    private lazy var underscoreStackView = UIStackView().then {
        $0.distribution = .fillEqually
        $0.spacing = 1
        $0.axis = .vertical
    }
    
    private lazy var weekStackView = UIStackView().then {
        $0.distribution = .fillEqually
        $0.spacing = 10
        $0.axis = .horizontal
    }
    
    private lazy var mondayView = UIView()
    private lazy var tuesdayView = UIView()
    private lazy var wednesdayView = UIView()
    private lazy var thursdayView = UIView()
    private lazy var fridayView = UIView()
    private lazy var saturdayView = UIView()
    private lazy var sundayView = UIView()
    
    // MARK: - Properties
    static let identifier = "RecordChartCell"
    
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
        contentView.addSubview(underscoreStackView)
        contentView.addSubview(weekStackView)
        
        let days = Week.allCases
        
        (1...9).forEach { _ in
            let backgrounView = UIView().then {
                $0.backgroundColor = .white
            }
            underscoreStackView.addArrangedSubview(backgrounView)
        }
        
        [mondayView, tuesdayView, wednesdayView, thursdayView, fridayView, saturdayView, sundayView]
            .enumerated()
            .forEach { (index, view) in
                view.backgroundColor = .clear
                
                let stackView = UIStackView().then {
                    $0.axis = .vertical
                }
                
                let label = UILabel().then {
                    $0.text = days[index].rawValue
                    $0.font = .systemFont(ofSize: 17, weight: .regular)
                    $0.textColor = UIColor(named: "PointLightColor")
                    $0.textAlignment = .center
                }
                
                stackView.addArrangedSubview(view)
                stackView.addArrangedSubview(label)
                
                label.snp.makeConstraints {
                    $0.height.equalTo(45)
                }
                
                weekStackView.addArrangedSubview(stackView)
        }
        
        configureUI()
    }
    
    private func configureUI() {
        contentView.backgroundColor = #colorLiteral(red: 0.6642269492, green: 0.6642268896, blue: 0.6642268896, alpha: 1)
        
        underscoreStackView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        weekStackView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    func bind(distanceArray: [Int]) {
        [mondayView, tuesdayView, wednesdayView, thursdayView, fridayView, saturdayView, sundayView].enumerated().forEach { (index, view) in
            view.subviews.forEach { $0.removeFromSuperview() }
            
            let customView = UIView().then {
                $0.backgroundColor = .red
            }
            
            view.addSubview(customView)
            
            customView.snp.makeConstraints {
                $0.bottom.leading.trailing.equalToSuperview()
                $0.height.equalTo(distanceArray[index] * 25)
            }
        }
    }
}
