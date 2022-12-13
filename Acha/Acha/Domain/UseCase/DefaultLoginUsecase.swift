//
//  LoginUsecase.swift
//  Acha
//
//  Created by hong on 2022/11/27.
//

import Foundation
import RxSwift
import RxRelay

final class DefaultLoginUseCase: LoginUseCase {
    
    var emailValidation: Bool = false
    var passwordValidation: Bool = false
    
    var emailRelay: RxRelay.BehaviorRelay<String> = .init(value: "")
    var passwordRelay: RxRelay.BehaviorRelay<String> = .init(value: "")
    private let repository: UserRepository
    
    init(repository: UserRepository) {
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
    
    func isLogInAble() -> Bool {
        return emailValidation && passwordValidation
    }
    
    func logIn() -> Observable<String> {
        let loginData = LoginData(email: emailRelay.value, password: passwordRelay.value)
        return repository.logIn(data: loginData).asObservable()
    }

}
