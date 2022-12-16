//
//  CommunityIndicatorCell.swift
//  Acha
//
//  Created by 배남석 on 2022/12/12.
//

import UIKit

final class CommunityIndicatorCell: UICollectionViewCell {
    // MARK: - UI properties
    var indicatorView: UIActivityIndicatorView = UIActivityIndicatorView().then {
        $0.style = .large
    }
    
    // MARK: - Properties
    static let identifier = "CommunityIndicatorCell"
    
    // MARK: - Lifecycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func setupViews() {
        contentView.addSubview(indicatorView)
    }
    
    private func configureUI() {        
        indicatorView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
