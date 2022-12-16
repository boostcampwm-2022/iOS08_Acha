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
        case noUserError
    }

    private let auth = FirebaseAuth.Auth.auth()
    private let disposeBag = DisposeBag()

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
                
                // 로그인 
                logIn(data: LoginData(email: data.email, password: data.password))
                    .subscribe(onSuccess: { _ in
                        single(.success(userDTO))
                    }, onFailure: { error in
                        single(.failure(error))
                    })
                    .disposed(by: disposeBag)
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
    
    public func delete() -> Single<Void> {
        Single<Void>.create { single in
            guard let user = Auth.auth().currentUser else {
                single(.failure(DefaultAuthError.noUserError))
                return Disposables.create()
            }
            user.delete { error in
                if let error {
                    single(.failure(error))
                } else {
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }
    
    public func update(email: String, password: String) -> Single<Void> {
        Single<Void>.create { single in
            guard let user = Auth.auth().currentUser,
                  let previousEmail = user.email else {
                single(.failure(DefaultAuthError.noUserError))
                return Disposables.create()
            }
            
            // 이메일을 업데이트하기 위해 사용자 재인증
            let credential = EmailAuthProvider.credential(withEmail: previousEmail,
                                                          password: password)
            user.reauthenticate(with: credential) { _, error in
                if let error {
                    single(.failure(error))
                } else {
                    user.updateEmail(to: email) { error in
                        if let error {
                            single(.failure(error))
                        } else {
                            single(.success(()))
                        }
                    }
                }
            }
            return Disposables.create()
        }
    }
}
