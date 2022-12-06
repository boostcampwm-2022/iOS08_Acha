//
//  BadgeRepository.swift
//  Acha
//
//  Created by  sangyeon on 2022/12/01.
//

import RxSwift

protocol BadgeRepository {
    func fetchAllBadges() -> Single<[Badge]>
    func fetchSomeBadges(ids: [Int]) -> Single<[Badge]>
}
