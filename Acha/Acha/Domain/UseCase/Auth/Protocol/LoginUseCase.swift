//
//  LoginUseCase.swift
//  Acha
//
//  Created by hong on 2022/12/12.
//

import Foundation
import RxSwift
import RxCocoa

protocol LoginUseCase: EmailValidatable, PasswordValidatable {
    var emailRelay: BehaviorRelay<String> {get set}
    var passwordRelay: BehaviorRelay<String> {get set}
    
    var emailValidation: Bool {get set}
    var passwordValidation: Bool {get set}

    func isLogInAble() -> Bool
    func logIn() -> Observable<String>
}
