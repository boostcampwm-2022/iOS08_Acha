//
//  AuthUseCase.swift
//  Acha
//
//  Created by hong on 2022/11/21.
//

import Foundation
import FirebaseAuth
import RxSwift

protocol SignUpAble {
    func signUp(data: SignUpData) -> Observable<Bool>
}

protocol LoginAble {
    func logIn(data: LoginData) -> Observable<Bool>
}

protocol EmailValidate {
    func emailValidate(text: String) -> Bool
}

protocol PasswordValidate {
    func passwordValidate(text: String) -> Bool
}

protocol NickNameValidate {
    func nickNameValidate(text: String) -> Bool
}

final class AuthUseCase: SignUpAble {
    
    public func signUp(data: SignUpData) -> Observable<Bool> {
        return Observable<Bool>.create { observer in
            FirebaseAuth.Auth.auth().createUser(
                withEmail: data.email,
                password: data.password
            ) { _, error in
                guard error == nil else {
                    observer.onNext(false)
                    return
                }
                observer.onNext(true)
            }
            return Disposables.create()
        }
    }
}
extension AuthUseCase: LoginAble {
    public func logIn(data: LoginData) -> Observable<Bool> {
        print(data)
        return Observable<Bool>.create { observer in
            FirebaseAuth.Auth.auth().signIn(withEmail: data.email,
                                            password: data.password) { result, error in
                guard error == nil else {
                    print(error)
                    observer.onNext(false)
                    return
                }
                guard let uid = result?.user.uid else {
                    observer.onNext(false)
                    return
                }
                observer.onNext(true)
            }
            return Disposables.create()
        }
    }
}

extension AuthUseCase: EmailValidate, PasswordValidate, NickNameValidate {
    public func emailValidate(text: String) -> Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return text.stringCheck(pattern: pattern)
    }
    
    public func passwordValidate(text: String) -> Bool {
        return text.count >= 6 ? true : false
    }
    
    public func nickNameValidate(text: String) -> Bool {
        return text.count >= 3 ? true : false
    }
}

struct SignUpData {
    let email: String
    let password: String
    let nickName: String
}

struct LoginData {
    let email: String
    let password: String
}
