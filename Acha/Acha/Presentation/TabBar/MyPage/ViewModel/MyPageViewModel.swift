//
//  MyPageViewModel.swift
//  Acha
//
//  Created by  sangyeon on 2022/12/01.
//

import Foundation
import RxSwift

final class MyPageViewModel: BaseViewModel {

    // MARK: - Input
    struct Input {
        var viewWillAppearEvent: Observable<Void>
        var badgeMoreButtonTapped: PublishSubject<Void>
        var editMyInfoTapped: PublishSubject<Void>
        var logoutTapped: PublishSubject<Void>
        var withDrawalTapped: PublishSubject<Void>
        var openSourceTapped: PublishSubject<Void>
    }
    
    // MARK: - Output
    struct Output {
        var nickName = PublishSubject<String>()
        var badges = PublishSubject<[Badge]>()
    }
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - Dependency
    private weak var coordinator: MyPageCoordinator?
    private var useCase: MyPageUseCase
    
    // MARK: - Lifecycles
    init(coordinator: MyPageCoordinator, useCase: MyPageUseCase) {
        self.coordinator = coordinator
        self.useCase = useCase
    }
    
    // MARK: - Helpers
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.viewWillAppearEvent
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.useCase.fetchMyPageData()
            }).disposed(by: disposeBag)
        
        input.badgeMoreButtonTapped
            .subscribe(onNext: { [weak self] in
                guard let self,
                      let allBadges = try? self.useCase.allBadges.value(),
                      let ownedBadges = try? self.useCase.ownedBadges.value() else { return }
                self.coordinator?.showBadgeViewController(allBadges: allBadges,
                                                          ownedBadges: ownedBadges)
            }).disposed(by: disposeBag)
        
        input.editMyInfoTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.coordinator?.showMyInfoEditViewController()
            }).disposed(by: disposeBag)
        
        Observable.merge(input.logoutTapped, input.withDrawalTapped)
            .debug()
            .subscribe(onNext: { [weak self] in
                guard let self,
                      let coordinator = self.coordinator else { return }
                coordinator.delegate?.didFinished(childCoordinator: coordinator)
            }).disposed(by: disposeBag)
        
        input.openSourceTapped
            .subscribe(onNext: {
                print("오픈소스 노션 safari로 오픈")
            }).disposed(by: disposeBag)
        
        useCase.nickName
            .bind(to: output.nickName)
            .disposed(by: disposeBag)
        
        useCase.ownedBadges
            .bind(to: output.badges)
            .disposed(by: disposeBag)
        
        return output
    }
    
}
