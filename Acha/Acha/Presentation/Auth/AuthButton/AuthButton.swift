//
//  AuthButton.swift
//  Acha
//
//  Created by hong on 2022/11/21.
//

import UIKit

class AuthButton: UIButton {

    init(color: UIColor, text: String) {
        super.init(frame: .zero)

        configure(color: color, text: text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension AuthButton {
    private func configure(color: UIColor, text: String) {
        backgroundColor = color
        setTitle(text, for: .normal)
        layer.cornerRadius = 10
        titleLabel?.font = .boldBody
    }
}
