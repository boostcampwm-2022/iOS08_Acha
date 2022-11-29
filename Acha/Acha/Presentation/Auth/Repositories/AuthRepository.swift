//
//  AuthRepository.swift
//  Acha
//
//  Created by hong on 2022/11/21.
//

import Foundation
import RxSwift
import RxRelay

// FIXME: AuthRepository에 사용되는 것은 공통으로 프로토콜로 분리하고
// AuthRepository를 상속하는 LoginReposity, SignUpRepository로 분리하는게 코드 관리 측면에서 좋아보입니다.
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

protocol LoginReposity {
    var emailRelay: BehaviorRelay<String> {get set}
    var passwordRelay: BehaviorRelay<String> {get set}
    
    var emailValidation: Bool {get set}
    var passwordValidation: Bool {get set}
    
    func getLoginData() -> Observable<LoginData>
    func isLoginAble() -> Bool

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

extension AuthRepository: LoginReposity {
    func getLoginData() -> RxSwift.Observable<LoginData> {
        return Observable
            .zip(emailRelay, passwordRelay)
            .map { (email, password) in
                return LoginData(email: email, password: password)
            }
    }
    
    func isLoginAble() -> Bool {
        return emailValidation == true && passwordValidation == true
    }
    
}
