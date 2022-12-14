//
//  MyInfoEditUseCase.swift
//  Acha
//
//  Created by  sangyeon on 2022/12/10.
//

import Foundation
import RxSwift

protocol MyInfoEditUseCase: EmailValidatable {
    func updateUserInfo(user: User, email: String, password: String) -> Single<Void>
}
