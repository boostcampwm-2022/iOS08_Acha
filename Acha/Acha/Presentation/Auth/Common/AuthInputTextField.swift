//
//  AuthInputTextField.swift
//  Acha
//
//  Created by hong on 2022/11/21.
//

import UIKit
import RxCocoa
import RxSwift

final class AuthInputTextField: UITextField {
    
    enum AuthTextFieldType {
        case email
        case password
        case nickName
        
        var image: UIImage {
            switch self {
            case .email:
                return .authEmailImage
            case .nickName:
                return .authNickNameImage
            case .password:
                return .authPasswordImage
            }
        }
        
        var placeholder: String {
            switch self {
            case .email:
                return "이메일"
            case .nickName:
                return "닉네임"
            case .password:
                return "패스워드"
            }
        }
    }
    
    private var disposeBag = DisposeBag()
    private var isThisTextFieldValidate = false {
        willSet {
            if newValue {
                rightViewMode = .never
            } else {
                rightViewMode = .unlessEditing
            }
        }
    }
    
    init(type: AuthTextFieldType) {
        super.init(frame: .zero)
        self.typeSetting(type: type)
        self.configureTextField()
        self.bindEdit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func validateUpdate(_ validate: Bool) {
        isThisTextFieldValidate = validate
    }
    
}

extension AuthInputTextField {
    
    private func configureTextField() {
        clearButtonMode = .always
        layer.cornerRadius = 10
        layer.borderWidth = 3
        layer.borderColor = UIColor.pointLight.cgColor
        returnKeyType = .next
        autocapitalizationType = .none
        spellCheckingType = .no
        autocorrectionType = .no
    }
    
    private func bindEdit() {
    
        rx.controlEvent([.editingDidEnd])
            .subscribe { [weak self] _ in
                self?.layer.borderColor = UIColor.pointLight.cgColor
            }
            .disposed(by: disposeBag)
        
        rx.controlEvent([.editingDidBegin])
            .subscribe { [weak self] _ in
                self?.layer.borderColor = UIColor.green.cgColor
            }
            .disposed(by: disposeBag)
    }
}

extension AuthInputTextField {
    private func typeSetting(type: AuthTextFieldType) {
        self.setIcon(image: type.image, location: .left)
        self.setIcon(image: .authInvalidateImage, location: .right)
        placeholder = type.placeholder
        if type == AuthTextFieldType.password {
            self.isSecureTextEntry = true
        }
    }
}
