//
//  AuthUseCase.swift
//  Acha
//
//  Created by hong on 2022/11/21.
//

import Foundation
import FirebaseAuth
import RxSwift
import FirebaseDatabase

protocol EmailValidate {
    func emailValidate(text: String) -> Bool
}

protocol PasswordValidate {
    func passwordValidate(text: String) -> Bool
}

protocol NickNameValidate {
    func nickNameValidate(text: String) -> Bool
}

struct LoginData: Equatable {
    let email: String
    let password: String
}
