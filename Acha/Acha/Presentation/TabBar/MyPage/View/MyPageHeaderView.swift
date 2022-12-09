//
//  MyPageHeaderView.swift
//  Acha
//
//  Created by 조승기 on 2022/11/30.
//

import UIKit
import Then
import SnapKit

final class MyPageHeaderView: UICollectionReusableView {
    // MARK: - UI properties
    private lazy var titleLabel: UILabel = UILabel().then {
        $0.font = .smallTitle
        $0.textColor = .white
    }
    private lazy var moreButton: UIButton = UIButton().then {
        $0.setTitle("더보기 >", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .tinyTitle
        $0.isHidden = true
    }
    
    // MARK: - Properties
    static let identifer = "MyPageHeaderView"
    private var moreButtonHandler: () -> Void = {}
    
    // MARK: - Lifecycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setUpMoreButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func configureUI() {
        backgroundColor = .pointLight
        layer.cornerRadius = 10
        
        [titleLabel, moreButton].forEach { addSubview($0) }
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.top.bottom.equalToSuperview().inset(10)
        }
        
        moreButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-15)
            $0.top.bottom.equalTo(titleLabel)
        }
    }
    
    private func setUpMoreButton() {
        moreButton.addTarget(self,
                             action: #selector(moreButtonDidClick),
                             for: .touchUpInside)
    }
    
    @objc func moreButtonDidClick() {
        moreButtonHandler()
    }
    
    func bind(title: String, moreButtonHandler: (() -> Void)?) {
        titleLabel.text = title
        if let handler = moreButtonHandler {
            moreButton.isHidden = false
            self.moreButtonHandler = handler
        }
    }
}
