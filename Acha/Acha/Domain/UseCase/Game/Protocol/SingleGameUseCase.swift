//
//  SingleGameUseCase.swift
//  Acha
//
//  Created by 조승기 on 2022/11/23.
//

import Foundation
import RxSwift

protocol SingleGameUseCase: MapBaseUseCase {
    var tapTimer: TimerService { get }
    var runningTimer: TimerService { get }
    
    var ishideGameOverButton: BehaviorSubject<Bool> { get }
    var previousCoordinate: Coordinate? { get set }
    var runningTime: BehaviorSubject<Int> { get set }
    var runningDistance: BehaviorSubject<Double> { get set }
    var wentLocations: PublishSubject<[Coordinate]> { get set }
    var visitLocations: PublishSubject<[Coordinate]> { get set }
    var tooFarFromLocaiton: BehaviorSubject<Bool> { get set }
    var visitedMapIndex: BehaviorSubject<Set<Int>> { get set }
    var gameOverInformation: PublishSubject<(Record, String, Badge?)> { get set }
    
    func start()
    func startGameOverTimer()
    func startRunningTimer()
    func stop()
    func gameOverButtonTapped()
    
    func healthKitWrite() -> Observable<Void>
    func healthKitAuthorization() -> Observable<Void>
}
