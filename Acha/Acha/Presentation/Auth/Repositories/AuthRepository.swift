//
//  AuthRepository.swift
//  Acha
//
//  Created by hong on 2022/11/21.
//

import Foundation
import RxSwift
import RxRelay

protocol SignUpRepository1 {
    var emailRelay: BehaviorRelay<String> {get set}
    var passwordRelay: BehaviorRelay<String> {get set}
    var nickNameRelay: BehaviorRelay<String> {get set}
    
    var emailValidation: Bool {get set}
    var passwordValidation: Bool {get set}
    var nickNameValidation: Bool {get set}
    
    func getSignUpdata() -> Observable<SignUpData>
    func isSignAble() -> Bool
}

protocol LoginReposity1 {
    var emailRelay: BehaviorRelay<String> {get set}
    var passwordRelay: BehaviorRelay<String> {get set}
    
    var emailValidation: Bool {get set}
    var passwordValidation: Bool {get set}
    
    func getLoginData() -> Observable<LoginData>
    func isLoginAble() -> Bool

}
