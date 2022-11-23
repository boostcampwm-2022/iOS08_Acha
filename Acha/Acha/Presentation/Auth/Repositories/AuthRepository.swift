//
//  AuthRepository.swift
//  Acha
//
//  Created by hong on 2022/11/21.
//

import Foundation
import RxSwift
import RxRelay

protocol SignUpRepository {
    var emailRelay: BehaviorRelay<String> {get set}
    var passwordRelay: BehaviorRelay<String> {get set}
    var nickNameRelay: BehaviorRelay<String> {get set}
    
    var emailValidation: Bool {get set}
    var passwordValidation: Bool {get set}
    var nickNameValidation: Bool {get set}
    
    func getSignUpdata() -> Observable<SignUpData>
    func isSignAble() -> Bool
}

final class AuthRepository: SignUpRepository {
    var emailValidation: Bool = false
    var passwordValidation: Bool = false
    var nickNameValidation: Bool = false
    
    var emailRelay: RxRelay.BehaviorRelay<String> = .init(value: "")
    
    var passwordRelay: RxRelay.BehaviorRelay<String> = .init(value: "")
    
    var nickNameRelay: RxRelay.BehaviorRelay<String> = .init(value: "")
    
    func getSignUpdata() -> RxSwift.Observable<SignUpData> {
        return Observable
            .zip(emailRelay, passwordRelay, nickNameRelay)
            .map { (email, password, nickName) in
                return SignUpData(email: email, password: password, nickName: nickName)
            }
    }
    
    func isSignAble() -> Bool {
        return emailValidation && passwordValidation && nickNameValidation
    }
}
