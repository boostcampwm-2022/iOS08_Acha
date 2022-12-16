//
//  SignUpUseCase.swift
//  Acha
//
//  Created by hong on 2022/12/12.
//

import Foundation
import RxSwift
import RxCocoa

protocol SignUpUsecase: EmailValidatable, PasswordValidatable, NickNameValidatable {
    var emailRelay: BehaviorRelay<String> {get set}
    var passwordRelay: BehaviorRelay<String> {get set}
    var nickNameRelay: BehaviorRelay<String> {get set}
    
    var emailValidation: Bool {get set}
    var passwordValidation: Bool {get set}
    var nickNameValidation: Bool {get set}
    
    func isSignAble() -> Bool
    func signUp() -> Observable<String>
}
