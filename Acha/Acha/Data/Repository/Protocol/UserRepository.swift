//
//  UserRepository.swift
//  Acha
//
//  Created by hong on 2022/12/02.
//
import Foundation
import RxSwift

protocol UserRepository {
    func getUUID() -> String?
    func fetchUserData() -> Single<User>
    func signUp(data: SignUpData) -> Single<UserDTO>
    func logIn(data: LoginData) -> Single<String>
    func signOut() -> Observable<Void>
    func delete() -> Single<Void>
    func updateUserData(user: User) -> Single<Void>
    func updateUserEmail(email: String, password: String) -> Single<Void>
}
