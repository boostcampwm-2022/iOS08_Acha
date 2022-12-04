//
//  AuthTitleView.swift
//  Acha
//
//  Created by hong on 2022/11/21.
//

import UIKit

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
