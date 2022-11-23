//
//  HomeViewModel.swift
//  Acha
//
//  Created by 배남석 on 2022/11/15.
//

import Foundation
import RxSwift
import RxRelay

final class HomeViewModel: BaseViewModel {

    struct Input {
        let singleGameModeDidTap: Observable<Void>
        let multiGameModeDidTap: Observable<Void>
    }
    
    struct Output {
        let multiGameModeTapped: Observable<Void>
    }
    
    var disposeBag = DisposeBag()
    private weak var coordinator: HomeCoordinator?
    private let useCase: HomeUseCase
    
    init(
        coordinator: HomeCoordinator,
        useCase: HomeUseCase
    ) {
        self.useCase = useCase
        self.coordinator = coordinator
    }
    
    func transform(input: Input) -> Output {
        
        let bag = DisposeBag()
        
        input.singleGameModeDidTap
            .subscribe { [weak self] _ in
                self?.coordinator?.connectSingleGameFlow()
            }
            .disposed(by: bag)
        
        let didMultiGameModeDidTap = Observable<Void>.create { observer in
            input.multiGameModeDidTap
                .subscribe { [weak self] _ in
                    print("tapped")
                    observer.onNext(())
                }
                .disposed(by: bag)
            return Disposables.create()
        }
        
        disposeBag = bag
        
        return Output(multiGameModeTapped: didMultiGameModeDidTap)
    }
}
