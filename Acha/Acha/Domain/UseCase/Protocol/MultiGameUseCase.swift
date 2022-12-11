//
//  MultiGameUseCase.swift
//  Acha
//
//  Created by hong on 2022/12/06.
//

import Foundation
import RxSwift

protocol MultiGameUseCase {
    
    func timerStart() -> Observable<Int>
    func timerStop()
    
    func getLocation() -> Observable<Coordinate>
    func point() -> Observable<Int>
    var visitedLocation: Set<Coordinate> {get set}
    var movedDistance: Double {get set}
    
    func healthKitStore(time: Int)
    func updateData(roomId: String)
    
    func stopObserveLocation()
    
    func observing(roomID: String) -> Observable<[MultiGamePlayerData]>
    func watchOthersLocation(roomID: String) -> Single<Coordinate>
    
    func leave(roomID: String)
}
