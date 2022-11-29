//
//  SingleGameUseCase.swift
//  Acha
//
//  Created by 조승기 on 2022/11/23.
//

import Foundation
import RxSwift

protocol SingleGameUseCase {
    var tapTimer: TimerServiceProtocol { get }
    var runningTimer: TimerServiceProtocol { get }
    
    var ishideGameOverButton: BehaviorSubject<Bool> { get }
    var previousCoordinate: Coordinate? { get set }
    var currentLocation: PublishSubject<Coordinate> { get set }
    var runningTime: BehaviorSubject<Int> { get set }
    var runningDistance: BehaviorSubject<Double> { get set }
    var wentLocations: PublishSubject<[Coordinate]> { get set }
    var visitLocations: PublishSubject<[Coordinate]> { get set }
    var tooFarFromLocaiton: BehaviorSubject<Bool> { get set }
    var visitedMapIndex: BehaviorSubject<Set<Int>> { get set }
    var gameOverInformation: PublishSubject<(Record, String)> { get set }
    
    func startRunning()
    func startGameOverTimer()
    func startRunningTimer()
    func stopRunningTimer()
    func gameOverButtonTapped()
}
