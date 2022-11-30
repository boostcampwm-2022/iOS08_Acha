//
//  CommunityMainViewModel.swift
//  Acha
//
//  Created by 배남석 on 2022/11/30.
//

import Foundation
import RxSwift
import RxRelay

final class CommunityMainViewModel: BaseViewModel {
    // MARK: - Input
    struct Input {
        var viewDidAppearEvent: Observable<Void>
    }
    
    // MARK: - Output
    struct Output {
        
    }
    
    // MARK: - Dependency
    var disposeBag = DisposeBag()
    private let useCase: CommunityMainUseCase!
    
    // MARK: - Lifecycles
    init(useCase: DefaultCommunityMainUseCase) {
        self.useCase = useCase
    }
    
    // MARK: - Helpers
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.viewDidAppearEvent
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
            }).disposed(by: disposeBag)
        
        return output
    }
   
}
