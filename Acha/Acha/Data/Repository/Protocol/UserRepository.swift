//
//  UserRepository.swift
//  Acha
//
//  Created by hong on 2022/12/01.
//

import Foundation
import RxSwift

protocol UserRepository {
    func getRoomUser(id: String) -> Single<RoomUser>
}
