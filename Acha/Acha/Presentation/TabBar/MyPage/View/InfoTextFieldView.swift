//
//  InfoTextFieldView.swift
//  Acha
//
//  Created by  sangyeon on 2022/12/08.
//

import UIKit
import SnapKit
import Then

final class InfoTextFieldView: UIView {
    
    // MARK: - UI properties
    private var label: UILabel = UILabel().then {
        $0.textColor = .pointLight
        $0.font = .title
    }
    
    var textField: UITextField = UITextField().then {
        $0.textColor = .black
        $0.layer.cornerRadius = 10
        $0.layer.borderColor = UIColor.pointLight.cgColor
        $0.layer.borderWidth = 2
        $0.addLeftRightPadding()
    }
    
    // MARK: - Properties
    
    // MARK: - Lifecycles
    init(frame: CGRect, title: String) {
        label.text = title
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension InfoTextFieldView {
    // MARK: - Helpers
    private func configureUI() {
        addSubview(label)
        addSubview(textField)
        
        label.snp.makeConstraints {
            $0.centerY.leading.equalToSuperview()
            $0.width.equalTo(60)
        }
        textField.snp.makeConstraints {
            $0.leading.equalTo(label.snp.trailing).offset(5)
            $0.trailing.centerY.equalToSuperview()
            $0.height.equalTo(40)
        }
    }

    func setContent(_ content: String) {
        textField.text = content
    }
}
