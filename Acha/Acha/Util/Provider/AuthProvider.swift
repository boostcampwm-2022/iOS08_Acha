//
//  AuthProvider.swift
//  Acha
//
//  Created by hong on 2022/11/27.
//

import Foundation
import RxSwift
import FirebaseDatabase
import FirebaseAuth

enum AuthError: Error {
     case serverError
     case signUpError
     case logInError
     case uidError
 }

protocol SignUpAble {
    func signUp(data: SignUpData) -> Observable<String>
}

protocol LoginAble {
    func logIn(data: LoginData) -> Observable<String>
}

protocol KeyChainStorable {
    func storeToKeyChain(id: String)
}

extension KeyChainStorable {
    func storeToKeyChain(id: String) {
        try? KeyChainManager.delete()
        try? KeyChainManager.save(id: id)
    }
}

protocol UserDataStorable {
    func store(data: UserDTO)
}

extension UserDataStorable {
    func store(data: UserDTO) {
        FBRealTimeDB().make(FBRealTimeDBType.user(id: data.id, data: data))
    }
}

struct AuthProvider: SignUpAble, LoginAble, KeyChainStorable, UserDataStorable {
    
    public func signUp(data: SignUpData) -> Observable<String> {
        return Observable<String>.create { observer in
            FirebaseAuth.Auth.auth().createUser(
                withEmail: data.email,
                password: data.password
            ) { result, error in
                guard error == nil else {
                    observer.onError(AuthError.serverError)
                    return
                }
                guard let userId = result?.user.uid else {
                    observer.onError(AuthError.uidError)
                    return
                }
                
                // 유저 데이터 추가
                let userDTO = data.toUserDTO(id: userId)
                store(data: userDTO)
                
                observer.onNext(userId)
            }
            return Disposables.create()
        }
    }
    
    public func logIn(data: LoginData) -> Observable<String> {
        
        return Observable<String>.create { observer in
            FirebaseAuth.Auth.auth().signIn(
                withEmail: data.email,
                password: data.password
            ) { result, error in
                guard error == nil else {
                    observer.onError(AuthError.serverError)
                    return
                }
                guard let uid = result?.user.uid else {
                    observer.onError(AuthError.uidError)
                    return
                }
                storeToKeyChain(id: uid)
                observer.onNext(uid)
            }
            return Disposables.create()
        }
    }
    
}
