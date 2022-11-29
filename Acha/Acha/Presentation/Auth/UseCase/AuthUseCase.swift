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

protocol UserDataAppendToDatabase {
  func userDataAppendToDatabase(userData: UserDTO)
}

protocol SignUpAble {
    func signUp(data: SignUpData) -> Observable<Result<String, Error>>
}

protocol LoginAble {
    func logIn(data: LoginData) -> Observable<Result<String, Error>>
}

// FIXME: 다른 곳에서 사용되지 않고 있고 Validate 하나로 합쳐서 사용할 수 있지 않을까요?
protocol EmailValidate {
    func emailValidate(text: String) -> Bool
}

protocol PasswordValidate {
    func passwordValidate(text: String) -> Bool
}

protocol NickNameValidate {
    func nickNameValidate(text: String) -> Bool
}


protocol KeyChainStorable {
    func storeToKeyChain(id: String) -> Observable<Result<String, Error>>
}

extension KeyChainStorable {
    func storeToKeyChain(id: String) -> Observable<Result<String, Error>> {
        return Observable<Result<String, Error>>.create { observer in
            do {
                // TODO: 삭제하고 순차적으로 잘 동작하나요? try가 되면 아래 문법이 실행되는게 맞긴하지만
                // try KeyChainManager.delete()에 대한 변수를 할당하고 실패(catch)시 nil 처리 후
                // nil이 아닌 케이스에 try KeyChainManager.save(id: id) 하는것이 더 안전해보입니다.
                // 잘된다면 적용안하셔도 됩니다.
                try KeyChainManager.delete()
                try KeyChainManager.save(id: id)
                observer.onNext(.success(id))
            } catch {
                observer.onNext(.failure(KeyChainManager.KeychainServiceError.saveIDError))
            }
            return Disposables.create()
        }
    }
}

final class AuthUseCase: KeyChainStorable {
    enum AuthError: Error {
         case serverError
         case signUpError
         case logInError
         case uidError
     }
}

extension AuthUseCase: SignUpAble {
    public func signUp(data: SignUpData) -> Observable<Result<String, Error>> {
        return Observable<Result<String, Error>>.create { observer in
            FirebaseAuth.Auth.auth().createUser(
                withEmail: data.email,
                password: data.password
            ) { result, error in
                guard error == nil else {
                    observer.onNext(.failure(AuthError.serverError))
                    return
                }
                guard let userId = result?.user.uid else {
                    observer.onNext(.failure(AuthError.uidError))
                    return
                }
                observer.onNext(.success(userId))
            }
            return Disposables.create()
        }
    }
}

extension AuthUseCase: LoginAble {
    public func logIn(data: LoginData) -> Observable<Result<String, Error>> {
        
        return Observable<Result<String, Error>>.create { observer in
            FirebaseAuth.Auth.auth().signIn(
                withEmail: data.email,
                password: data.password
            ) { result, error in
                guard error == nil else {
                    observer.onNext(.failure(AuthError.serverError))
                    return
                }
                guard let uid = result?.user.uid else {
                    observer.onNext(.failure(AuthError.uidError))
                    return
                }
                observer.onNext(.success(uid))
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

extension AuthUseCase: UserDataAppendToDatabase {
    public func userDataAppendToDatabase(userData: UserDTO) {
        let ref = Database.database().reference()
        ref.child("User/\(userData.id)").setValue(userData.dictionary)
    }
}

// FIXME: 글로벌하게 접근이 가능할거면 별도 파일로 분리하거나 AuthUseCase 스코프 안에서 선언하여 네임스페이스로 분리해주시는게 좋을거 같아요
struct LoginData: Equatable {
    let email: String
    let password: String
}
