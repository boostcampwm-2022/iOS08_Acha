//
//  MultiGameRoomDataSource.swift
//  Acha
//
//  Created by hong on 2022/11/24.
//

import Foundation
import RxSwift

protocol MultiGameRoomDataSourceProtocol {
    // 방 만들기
    func make(roomID: String)
    // 방 데이터 얻기
//    func get(roomID: String) -> Observable<RoomDTO>
    // 방 폭파
//    func delete(roomID: String)
    // 방 정보 변경
//    func edit(_ type: FBRealTimeDBType) -> Observable<RoomDTO>
}

struct MultiGameRoomDataSource: MultiGameRoomDataSourceProtocol {
    
    private let provider: FBRealTimeDB
    
    init(provider: FBRealTimeDB) {
        self.provider = provider
    }
    
    func make(roomID: String) {
        provider.make(.room(id: roomID, data: nil))
    }
    
    private func getUUID() -> String? {
        return try? KeyChainManager.get()
    }
    
//    func get(roomID: String) -> Observable<RoomDTO> {
//
//        return Observable.create { observer in
//            guard let uuid = try? KeyChainManager.get() else {return}
//            provider.get(.room(id: roomID, data: nil))
//                .subscribe { <#_#> in
//                    <#code#>
//                }
//            observer.onNext(<#T##element: RoomDTO##RoomDTO#>)
//            return Disposables.create()
//        }
//    }
//
//    func delete(roomID: String) {
//        let rootRef = ref.child(type.path)
//        rootRef.removeValue()
//    }
}
