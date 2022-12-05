//
//  DefaultAuthService.swift
//  Acha
//
//  Created by hong on 2022/12/02.
//
import Foundation
import FirebaseAuth
import RxSwift

struct DefaultAuthService: AuthService {

    enum DefaultAuthError: Error {
         case serverError
         case signUpError
         case logInError
         case uidError
         case signOutError
     }

    private let auth = FirebaseAuth.Auth.auth()

    public func signUp(data: SignUpData) -> Single<UserDTO> {
        return Single<UserDTO>.create { single in
            auth.createUser(
                withEmail: data.email,
                password: data.password
            ) { result, error in
                guard error == nil else {
                    single(.failure(DefaultAuthError.serverError))
                    return
                }
                guard let userId = result?.user.uid else {
                    single(.failure(DefaultAuthError.uidError))
                    return
                }

                // 유저 데이터 추가
                let userDTO = data.toUserDTO(id: userId)

                single(.success(userDTO))
            }
            return Disposables.create()
        }
    }

    public func logIn(data: LoginData) -> Single<String> {

        return Single<String>.create { single in
            auth.signIn(
                withEmail: data.email,
                password: data.password
            ) { result, error in
                guard error == nil else {
                    single(.failure(DefaultAuthError.serverError))
                    return
                }
                guard let uuid = result?.user.uid else {
                    single(.failure(DefaultAuthError.uidError))
                    return
                }
                single(.success(uuid))
            }
            return Disposables.create()
        }
    }

    public func signOut() throws {
        try auth.signOut()
    }
}
