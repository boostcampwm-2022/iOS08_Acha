//
//  MyPageHeaderView.swift
//  Acha
//
//  Created by 조승기 on 2022/11/30.
//

import UIKit
import Then
import SnapKit

class MyPageHeaderView: UICollectionReusableView {
    // MARK: - UI properties
    private lazy var titleLabel: UILabel = UILabel().then {
        $0.font = .smallTitle
    }
    private lazy var moreButton: UIButton = UIButton().then {
        $0.setTitle("더보기 >", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .postBody
        $0.isHidden = true
    }
    // MARK: - Properties
    static let identifer = "MyPageHeaderView"
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
        [titleLabel, moreButton].forEach { addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.top.bottom.equalToSuperview().inset(10)
        }
        
        moreButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-15)
            $0.top.bottom.equalTo(titleLabel)
            $0.width.equalTo(70)
        }
    }
    
    func bind(title: String, isHiddenMoreButton: Bool = true) {
        titleLabel.text = title
        moreButton.isHidden = isHiddenMoreButton
    }
}