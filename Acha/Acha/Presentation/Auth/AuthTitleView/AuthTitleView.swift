//
//  AuthTitleView.swift
//  Acha
//
//  Created by hong on 2022/11/21.
//

import UIKit

class AuthTitleView: UIStackView {
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }

    private let label = UILabel().then {
        $0.font = .largeTitle
        $0.textAlignment = .center
    }
    
    init(image: UIImage?, text: String) {
        imageView.image = image
        label.text = text
        super.init(frame: .zero)
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
    }
}
