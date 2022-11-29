//
//  AuthTitleView.swift
//  Acha
//
//  Created by hong on 2022/11/21.
//

import UIKit

// FIXME: Auth에 사용되는 컴포넌트의 경우 컴포넌트 그룹을 하나 만들어서 정리하는게 깔끔해보입니다.
final class AuthTitleView: UIStackView {
    
    lazy var label = UILabel().then {
        $0.font = .largeTitle
        $0.textAlignment = .center
    }
    
    init(image: UIImage?, text: String) {
        super.init(frame: .zero)
        label.text = text
        configure()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension AuthTitleView {
    private func configure() {
        axis = .horizontal
        layout()
    }
    
    private func layout() {
        addViews()
        addConstraints()
    }
    
    private func addViews() {
        addArrangedSubview(label)
    }
    
    private func addConstraints() {
        label.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
}
