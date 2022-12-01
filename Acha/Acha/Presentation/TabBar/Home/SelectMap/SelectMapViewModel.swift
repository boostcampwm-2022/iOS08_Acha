//
//  SelectMapViewModel.swift
//  Acha
//
//  Created by 조승기 on 2022/11/14.
//

import Foundation
import RxSwift
import RxCocoa

final class SelectMapViewModel: MapBaseViewModel {
    
    // MARK: - Input
    struct Input {
        var viewWillAppearEvent: Observable<Void>
        var mapSelected: PublishSubject<Map>
        var regionDidChanged: PublishSubject<MapRegion>
        var startButtonTapped: Observable<Void>
        var backButtonTapped: Observable<Void>
    }
    
    // MARK: - Output
    struct Output {
        var visibleMaps = PublishRelay<[Map]>()
        var cannotStart = PublishRelay<Void>()
        var selectedMapRankings = PublishRelay<(String, [Record])>()    // map name, ranking
    }
    
    // MARK: - Dependency
    private weak var coordinator: SingleGameCoordinator?
    private var useCase: SelectMapUseCase
    
    // MARK: - Lifecycles
    init(coordinator: SingleGameCoordinator?, selectMapUseCase: SelectMapUseCase) {
        self.coordinator = coordinator
        self.useCase = selectMapUseCase
        super.init(useCase: selectMapUseCase)
    }
    
    // MARK: - Helpers
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.viewWillAppearEvent
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.useCase.start()
            })
            .disposed(by: disposeBag)
        
        input.mapSelected
            .subscribe(onNext: { [weak self] selectedMap in
                guard let self else { return }
                self.useCase.mapSelected(selectedMap)
                    .asObservable()
                    .bind(to: output.selectedMapRankings)
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.regionDidChanged
            .subscribe(onNext: { [weak self] region in
                guard let self else { return }
                let mapsToDisplay = self.useCase.getMapsInUpdatedRegion(region: region)
                output.visibleMaps.accept(mapsToDisplay)
            })
            .disposed(by: disposeBag)
        
        input.startButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                if self.useCase.isStartable() {
                    guard let selectedMap = self.useCase.selectedMap else { return }
                    self.coordinator?.showSingleGamePlayViewController(selectedMap: selectedMap)
                } else {
                    output.cannotStart.accept(())
                }
            })
            .disposed(by: disposeBag)
        
        input.backButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self,
                      let coordinator = self.coordinator else { return }
                coordinator.delegate?.didFinished(childCoordinator: coordinator)
            })
            .disposed(by: disposeBag)
    
        return output
    }
}
