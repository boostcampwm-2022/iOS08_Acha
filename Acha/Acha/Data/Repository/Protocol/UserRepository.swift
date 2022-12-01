//
//  UserRepository.swift
//  Acha
//
//  Created by  sangyeon on 2022/12/01.
//

import RxSwift

protocol UserRepository {
    func fetchUserData() -> Single<User>
}
