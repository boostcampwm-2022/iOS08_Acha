//
//  MyPageUseCase.swift
//  Acha
//
//  Created by  sangyeon on 2022/12/01.
//

import RxSwift

protocol MyPageUseCase {
    var userInfo: User? { get set }
    var nickName: PublishSubject<String> { get set }
    var ownedBadges: BehaviorSubject<[Badge]> { get set }
    var recentlyOwnedBadges: BehaviorSubject<[Badge]> { get set }
    var allBadges: BehaviorSubject<[Badge]> { get set }
    func fetchMyPageData()
}
