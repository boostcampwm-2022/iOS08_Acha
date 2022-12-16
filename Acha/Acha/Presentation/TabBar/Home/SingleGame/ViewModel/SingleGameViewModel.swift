//
//  SingleGameViewModel.swift
//  Acha
//
//  Created by 조승기 on 2022/11/15.
//

import Foundation
import RxRelay
import RxSwift

final class SingleGameViewModel: MapBaseViewModel {
    
    struct Input {
        var viewDidAppear: Observable<Void>
        var gameOverButtonTapped: Observable<Void>
        var rankButtonTapped: Observable<Void>
        var recordButtonTapped: Observable<Void>
        var mapTapped: Observable<Void>
        var gameOverOkButtonTapped: Observable<Void>
    }
    struct Output {
        var ishideGameOverButton = BehaviorSubject<Bool>(value: true)
        var currentLocation = PublishSubject<Coordinate>()
        var runningTime = BehaviorSubject<Int>(value: 0)
        var runningDistance = BehaviorSubject<Double>(value: 0)
        var tooFarFromLocation = BehaviorSubject<Bool>(value: false)
        
        var wentLocations = PublishSubject<[Coordinate]>()
        var visitLocations = PublishSubject<[Coordinate]>()
        var gameOverInformation = PublishSubject<(Record, String, Badge?)>()
    }
    
    // MARK: - Dependency
    let map: Map
    private let coordinator: SingleGameCoordinator
    private let useCase: SingleGameUseCase
    private var hideButtonTimer: DispatchSourceTimer?
    
    // MARK: - Lifecycle
    init(map: Map,
         coordinator: SingleGameCoordinator,
         singleGameUseCase: SingleGameUseCase) {
        self.map = map
        self.coordinator = coordinator
        self.useCase = singleGameUseCase
        super.init(useCase: useCase)
    }
    
    // MARK: - Helpers
    func transform(input: Input) -> Output {
        createInput(input: input)
        useCase.start()
        return createOutput()
    }
    
    private func createInput(input: Input) {
        input.viewDidAppear
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.useCase.healthKitAuthorization()
                    .subscribe()
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.gameOverButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.useCase.gameOverButtonTapped()
            }).disposed(by: disposeBag)
        
        input.rankButtonTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.coordinator.showInGameRankViewController(mapID: self.map.mapID)
            }).disposed(by: disposeBag)
        
        input.recordButtonTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.coordinator.showInGameRecordViewController(mapID: self.map.mapID)
            }).disposed(by: disposeBag)
        
        input.mapTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.useCase.startGameOverTimer()
            }).disposed(by: disposeBag)
        
        input.gameOverOkButtonTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.useCase.healthKitWrite()
                    .subscribe()
                    .disposed(by: self.disposeBag)
                self.coordinator.delegate?.didFinished(childCoordinator: self.coordinator)
            }).disposed(by: disposeBag)
    }
    
    private func createOutput() -> Output {
        let output = Output()
        useCase.userLocation
            .bind(to: output.currentLocation)
            .disposed(by: disposeBag)
        useCase.runningTime
            .bind(to: output.runningTime)
            .disposed(by: disposeBag)
        useCase.runningDistance
            .bind(to: output.runningDistance)
            .disposed(by: disposeBag)
        useCase.wentLocations
            .bind(to: output.wentLocations)
            .disposed(by: disposeBag)
        useCase.visitLocations
            .bind(to: output.visitLocations)
            .disposed(by: disposeBag)
        useCase.ishideGameOverButton
            .bind(to: output.ishideGameOverButton)
            .disposed(by: disposeBag)
        useCase.tooFarFromLocaiton
            .bind(to: output.tooFarFromLocation)
            .disposed(by: disposeBag)
        useCase.gameOverInformation
            .bind(to: output.gameOverInformation)
            .disposed(by: disposeBag)
        return output
    }
}
