//
//  RecordAndTimeBar.swift
//  Acha
//
//  Created by hong on 2022/11/15.
//

import UIKit

protocol DistanceAndTimeBarLine {
    var distanceAndTimeBar: DistanceAndTimeBar {get set}
    /// 거리, 시간 레이블 중간에 선 나오게 하는 메서드
    func distanceAndTimeBarMiddleLineAdjust(color: UIColor, width: CGFloat)
    /// 바텀 탭과 거리, 시간 레이블이 색이여서 선택된 색상의 선으로 구분 해주는 메서드 
    func distanceAndTimeBarBottomLineAdjust(color: UIColor, width: CGFloat)
}

extension DistanceAndTimeBarLine {
    func distanceAndTimeBarMiddleLineAdjust(color: UIColor, width: CGFloat) {
        distanceAndTimeBar.distanceLabel.layer.addBorder(directions: [.right], color: color, width: width)
        distanceAndTimeBar.distanceTitleLabel.layer.addBorder(directions: [.right], color: color, width: width)
    }
    
    func distanceAndTimeBarBottomLineAdjust(color: UIColor, width: CGFloat) {
        distanceAndTimeBar.layer.addBorder(directions: [.bottom], color: color, width: width)
    }
}

final class DistanceAndTimeBar: UIView {
    
    // MARK: - UI properties
    let distanceTitleLabel: PaddingLabel = {
        let label = PaddingLabel(topInset: 0, bottomInset: 0, leftInset: 20, rightInset: 0)
        label.font = .title
        label.textColor = .white
        label.textAlignment = .left
        label.text = "거리"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let distanceLabel: PaddingLabel = {
        let label = PaddingLabel(topInset: 0, bottomInset: 0, leftInset: 0, rightInset: 20)
        label.font = .title
        label.textColor = .white
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let timeTitleLabel: PaddingLabel = {
        let label = PaddingLabel(topInset: 0, bottomInset: 0, leftInset: 20, rightInset: 0)
        label.font = .title
        label.textColor = .white
        label.textAlignment = .left
        label.text = "시간"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let timeLabel: PaddingLabel = {
        let label = PaddingLabel(topInset: 0, bottomInset: 0, leftInset: 0, rightInset: 20)
        label.font = .title
        label.textColor = .white
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // MARK: - Properties
    
    // MARK: - Lifecycles

    init() {
        super.init(frame: .zero)
        layout()
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .pointLight
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Helpers
extension DistanceAndTimeBar {
    private func layout() {
        addViews()
        layoutViews()
    }
    
    private func addViews() {
        addSubview(distanceTitleLabel)
        addSubview(distanceLabel)
        addSubview(timeTitleLabel)
        addSubview(timeLabel)
    }
    
    private func layoutViews() {
        NSLayoutConstraint.activate([
            distanceTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            distanceTitleLabel.topAnchor.constraint(equalTo: topAnchor),
            distanceTitleLabel.trailingAnchor.constraint(equalTo: centerXAnchor),
            distanceTitleLabel.bottomAnchor.constraint(equalTo: centerYAnchor),
            
            distanceLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            distanceLabel.topAnchor.constraint(equalTo: distanceTitleLabel.bottomAnchor),
            distanceLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            distanceLabel.trailingAnchor.constraint(equalTo: centerXAnchor),
            
            timeTitleLabel.leadingAnchor.constraint(equalTo: distanceLabel.trailingAnchor),
            timeTitleLabel.topAnchor.constraint(equalTo: topAnchor),
            timeTitleLabel.bottomAnchor.constraint(equalTo: centerYAnchor),
            timeTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            timeLabel.leadingAnchor.constraint(equalTo: distanceLabel.trailingAnchor),
            timeLabel.topAnchor.constraint(equalTo: timeTitleLabel.bottomAnchor),
            timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

    }
}
