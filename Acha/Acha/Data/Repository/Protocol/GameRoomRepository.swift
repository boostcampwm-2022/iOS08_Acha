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
    
    /// 방을 만드는 메서드입니다. ( 입장 포함 ) ... 방 번호 리턴
    func makeRoom() -> Observable<String>
    
    /// 방을 떠나는 메서드입니다.
    func leaveRoom(id: String)
    
    /// 방을 삭제하는 메서드입니다.
    func deleteRoom(id: String)
    
    /// 원하는 방의 상황을 옵저빙 할 수 있는 메서드입니다.
    func observingRoom(id: String) -> Observable<RoomDTO>
    
    /// [RoomUser] 형태로 변경 해주는 메서드입니다.
    func observingRoomUser(id: String) -> Observable<[RoomUser]>
    
    /// observer 해제 ( observing 하고 안 할때 풀어줘야 합니다 )
    func removeObserverRoom(id: String)
    
    /// 게임 유저 데이터 불러 오기 ... observing 사용 ... 해제 필요 
    func observingMultiGamePlayers(id: String) -> Observable<[MultiGamePlayerData]>
    
    /// 게임 룸 업데이트 메서드 
    func updateMultiGamePlayer(
        roomId: String,
        data: MultiGamePlayerData,
        histroy: [Coordinate]
    )
    
    /// 게임 시작시 인 게임 데이터 만들기 
    func startGame(roomId: String)
    
    /// 룸 챗 옵저빙 
    func observingChats(id: String) -> Observable<[ChatDTO]>
    
    /// 읽은 정보 업데이트
    func updateReads(roomID: String, reads: [[String]])
    
    /// 쳇 업데이트
    func updateChats(roomID: String, chat: Chat)
}
