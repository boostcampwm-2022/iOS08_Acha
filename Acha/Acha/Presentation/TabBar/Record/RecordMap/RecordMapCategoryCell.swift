//
//  RecordMapCategoryCell.swift
//  Acha
//
//  Created by 배남석 on 2022/11/22.
//

import UIKit

class RecordMapCategoryCell: UICollectionViewCell {
    // MARK: - UI properties
    private lazy var locationNameLabel = UILabel().then {
        $0.layer.backgroundColor = UIColor.pointLight.cgColor
        $0.layer.cornerRadius = 15
        $0.font = UIFont.boldBody
        $0.textColor = .white
        $0.textAlignment = .center
    }
    // MARK: - Properties
    static let identifier = "RecordMapCategoryCell"
    
    // MARK: - Lifecycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSubviews()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    private func setUpSubviews() {
        contentView.addSubview(locationNameLabel)
    }
    
    private func configureUI() {
        locationNameLabel.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    func setLocationName(name: String) {
        locationNameLabel.text = name
    }
    
    func getLocationName() -> String {
        guard let name = locationNameLabel.text else { return "" }
        return name
    }
}
