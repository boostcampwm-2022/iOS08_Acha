//
//  SettingCell.swift
//  Acha
//
//  Created by  sangyeon on 2022/12/01.
//

import UIKit
import Then
import SnapKit

final class SettingCell: UICollectionViewCell {
    // MARK: - UI properties
    private lazy var button: UIButton = UIButton().then {
        $0.titleLabel?.font = .commentBody
        $0.setTitleColor(.black, for: .normal)
        $0.contentHorizontalAlignment = .left
    }

    // MARK: - Properties
    static let identifer = "SettingCell"
    var buttonHandler: (() -> Void)?
    
    // MARK: - Lifecycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func setupSubviews() {
        addSubview(button)
        
        button.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(10)
        }
    }
    
    private func setupButton() {
        button.addTarget(self,
                         action: #selector(buttonDidClick),
                         for: .touchUpInside)
    }
    
    @objc func buttonDidClick() {
        buttonHandler?()
    }
    
    func bind(title: String, handler: (() -> Void)?) {
        button.setTitle(title, for: .normal)
        self.buttonHandler = handler
    }
}
