//
//  GameRoomRepository.swift
//  Acha
//
//  Created by hong on 2022/12/05.
//

import Foundation
import RxSwift

protocol GameRoomRepository {
    /// RoomDTO 전부를 끌고 오는 메서드 입니다
    func fetchRoomData(id: String) -> Single<RoomDTO>
    
    /// RoomDTO 를 RoomUser 로 변환 하고 리턴하는 메서드 입니다
    func fetchRoomUserData(id: String) -> Single<[RoomUser]>
    
    /// 방에 들어가는 메서드 입니다
    func enterRoom(id: String) -> Single<[RoomUser]>
    
    /// 방을 만드는 메서드입니다. ( 입장 포함 )
    func makeRoom(id: String)
    
    /// 방을 떠나는 메서드입니다.
    func leaveRoom(id: String)
    
    /// 방을 삭제하는 메서드입니다.
    func deleteRoom(id: String)
    
    /// 원하는 방의 상황을 옵저빙 할 수 있는 메서드입니다.
    func observingRoom(id: String) -> Observable<RoomDTO>
}
