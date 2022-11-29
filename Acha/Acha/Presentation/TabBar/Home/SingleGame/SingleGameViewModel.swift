//
//  SingleGameViewModel.swift
//  Acha
//
//  Created by 조승기 on 2022/11/15.
//

import Foundation
import RxRelay
import RxSwift

final class SingleGameViewModel {
    
    struct Input {
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
        var tooFarFromLocaiton = BehaviorSubject<Bool>(value: false)
        
        var wentLocations = PublishSubject<[Coordinate]>()
        var visitLocations = PublishSubject<[Coordinate]>()
        var gameOver = PublishSubject<[Record]>()
    }
    
    // MARK: - Dependency
    let map: Map
    private let coordinator: SingleGameCoordinator
    private let useCase: SingleGameUseCase
    private var disposeBag = DisposeBag()
  
    // MARK: - Lifecycle
    init(map: Map,
         coordinator: SingleGameCoordinator,
         singeGameUseCase: SingleGameUseCase) {
        self.map = map
        self.coordinator = coordinator
        self.useCase = singeGameUseCase
    }
    
    // MARK: - Helpers
    func transform(input: Input) -> Output {
        createInput(input: input)
        useCase.startRunning()
        return createOutput()
    }
    
    private func createInput(input: Input) {
        input.gameOverButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.gameOver(isCompleted: false)
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
                self?.useCase.startGameOverTimer()
            }).disposed(by: disposeBag)
    }
    
    private func createOutput() -> Output {
        let output = Output()
        useCase.currentLocation
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
            .bind(to: output.tooFarFromLocaiton)
            .disposed(by: disposeBag)
        useCase.isGameOver
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.gameOver(isCompleted: true)
            }).disposed(by: disposeBag)
        return output
    }
    
    private func gameOver(isCompleted: Bool) {
        let time = (try? useCase.runningTime.value()) ?? 0
        let distance = (try? useCase.runningDistance.value()) ?? 0
        let createdAt = Date().convertToStringFormat(format: "yyyy-MM-dd")
        
        let kcal = Int(0.1128333333*Double(time))
        let record = Record(id: 0,
                            mapID: self.map.mapID,
                            userID: "마끼",
                            calorie: kcal,
                            distance: Int(distance),
                            time: time,
                            isSingleMode: true,
                            isCompleted: isCompleted,
                            createdAt: createdAt)
        
        self.coordinator.showSingleGameOverViewController(record: record,
                                                          map: map)
        self.disposeBag = DisposeBag()
    }
}
