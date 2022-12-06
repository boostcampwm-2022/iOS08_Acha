//
//  MultiGameRoomUseCase.swift
//  Acha
//
//  Created by hong on 2022/12/06.
//

import Foundation
import RxSwift

protocol MultiGameRoomUseCase {
    func observing(roomID: String) -> Observable<[RoomUser]>
    func get(roomID: String) -> Single<[RoomUser]>
    func leave(roomID: String)
    func removeObserver(roomID: String)
    func isGameAvailable(roomID: String) -> Observable<Void>
    func startGame(roomID: String)
}
