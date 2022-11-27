//
//  SignUpUsecase.swift
//  Acha
//
//  Created by hong on 2022/11/27.
//

import Foundation
import RxSwift
import RxRelay

final class SignUpUsecase {
    
    var emailValidation: Bool = false
    var passwordValidation: Bool = false
    var nickNameValidation: Bool = false
    
    var emailRelay: RxRelay.BehaviorRelay<String> = .init(value: "")
    var passwordRelay: RxRelay.BehaviorRelay<String> = .init(value: "")
    var nickNameRelay: RxRelay.BehaviorRelay<String> = .init(value: "")
    
    private let repository: SignUpRepositoryProtocol
    
    init(repository: SignUpRepositoryProtocol) {
        self.repository = repository
    }
    
    @discardableResult
    public func emailValidate(text: String) -> Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        emailValidation = text.stringCheck(pattern: pattern)
        if emailValidation { emailRelay.accept(text) }
        return emailValidation
    }
    
    @discardableResult
    public func passwordValidate(text: String) -> Bool {
        passwordValidation = text.count >= 6 ? true : false
        if passwordValidation { passwordRelay.accept(text) }
        return passwordValidation
    }
    
    @discardableResult
    public func nickNameValidate(text: String) -> Bool {
        nickNameValidation = text.count >= 3 ? true : false
        if nickNameValidation { nickNameRelay.accept(text) }
        return nickNameValidation
    }
    
    func isSignAble() -> Bool {
        return emailValidation && passwordValidation && nickNameValidation
    }
    
    func signUp() -> Observable<String> {
        let signUpData = SignUpData(
            email: emailRelay.value,
            password: passwordRelay.value,
            nickName: nickNameRelay.value
        )
        return repository.signUp(data: signUpData)
    }
}
