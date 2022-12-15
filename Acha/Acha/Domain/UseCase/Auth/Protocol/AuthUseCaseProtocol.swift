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

protocol EmailValidatable {
    func emailValidate(text: String) -> Bool
}

protocol PasswordValidatable {
    func passwordValidate(text: String) -> Bool
}

protocol NickNameValidatable {
    func nickNameValidate(text: String) -> Bool
}
