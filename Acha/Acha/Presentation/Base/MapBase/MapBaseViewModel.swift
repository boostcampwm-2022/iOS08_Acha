//
//  MapBaseViewModel.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/28.
//

import Foundation
import RxSwift

class MapBaseViewModel: BaseViewModel {

    // MARK: - Input
    struct Input {
        let viewWillDisappearEvent: Observable<Void>
        let focusButtonTapped: Observable<Void>
    }
    // MARK: - Output
    struct Output {
        var user = PublishSubject<User>()
        var isAvailableLocationAuthorization = PublishSubject<(Bool, Coordinate?)>()
        var focusUserEvent = PublishSubject<Coordinate>()
    }
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - Dependency
    let mapBaseUseCase: MapBaseUseCase
    
    // MARK: - Lifecycles
    init(useCase: MapBaseUseCase) {
        self.mapBaseUseCase = useCase
    }
    
    // MARK: - Helpers
    func transform(input: Input) -> Output {
        let output = Output()
        
        mapBaseUseCase.user
            .bind(to: output.user)
            .disposed(by: disposeBag)

        input.viewWillDisappearEvent
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.mapBaseUseCase.stop()
            })
            .disposed(by: disposeBag)
        
        input.focusButtonTapped
            .subscribe(onNext: { [weak self] in
                guard let self,
                      let userLocation = try? self.mapBaseUseCase.userLocation.value() else { return }
                output.focusUserEvent.onNext(userLocation)
            })
            .disposed(by: disposeBag)
        
        mapBaseUseCase.isAvailableLocationAuthorization()
            .bind(to: output.isAvailableLocationAuthorization)
            .disposed(by: disposeBag)
        
        return output
    }
}
