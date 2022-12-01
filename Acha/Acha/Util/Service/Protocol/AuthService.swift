//
//  AuthService.swift
//  Acha
//
//  Created by hong on 2022/12/02.
//

import Foundation
import RxSwift

protocol AuthService {
    
    func signUp(data: SignUpData) -> Single<UserDTO>
    func logIn(data: LoginData) -> Single<String>
}
