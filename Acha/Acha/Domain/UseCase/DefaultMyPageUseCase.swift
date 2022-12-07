//
//  DefaultMyPageUseCase.swift
//  Acha
//
//  Created by  sangyeon on 2022/12/01.
//

import RxSwift

final class DefaultMyPageUseCase: MyPageUseCase {
    // MARK: - Properties
    private var disposeBag = DisposeBag()
    var userInfo: User?
    var nickName = PublishSubject<String>()
    var ownedBadges = BehaviorSubject<[Badge]>(value: [])
    var allBadges = BehaviorSubject<[Badge]>(value: [])
    
    // MARK: - Dependencies
    private let userRepository: UserRepository
    private let badgeRepository: BadgeRepository
    
    // MARK: - LifeCycles
    init(userRepository: UserRepository, badgeRepository: BadgeRepository) {
        self.userRepository = userRepository
        self.badgeRepository = badgeRepository
    }
    
    // MARK: - Helpers
    
    func fetchMyPageData() {
        userRepository.fetchUserData()
            .asObservable()
            .subscribe(onNext: { [weak self] (user: User) in
                guard let self else { return }
                self.userInfo = user
                self.nickName.onNext(user.nickName)
                
                self.badgeRepository.fetchAllBadges()
                    .asObservable()
                    .subscribe(onNext: { [weak self] badges in
                        guard let self else { return }
                        self.allBadges.onNext(badges)
                        let ownedBadges = badges.filter { user.badges.contains($0.id) }
                        self.ownedBadges.onNext(ownedBadges)
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
    
    func logout() -> Observable<Void> {
        userRepository.signOut()
    }
    
    func deleteUser() -> Single<Void> {
        userRepository.delete()
    }
}
