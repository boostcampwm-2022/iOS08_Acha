//
//  MultiGameRoomRepository.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import Foundation
import RxSwift

protocol MultiGameRoomRepositoryProtocol {
    func make(roomID: String)
    func get(roomID: String) -> Observable<[RoomUser]>
    func leave(roomID: String)
}

struct MultiGameRoomRepository: MultiGameRoomRepositoryProtocol {
    private let disposebag = DisposeBag()
    private let dataSource: MultiGameRoomDataSourceProtocol
    init(dataSource: MultiGameRoomDataSourceProtocol) {
        self.dataSource = dataSource
    }
    func make(roomID: String) {
        dataSource.make(roomID: roomID)
    }
    
    func get(roomID: String) -> Observable<[RoomUser]> {
        return Observable<[RoomUser]>.create { observer in
            dataSource.get(roomID: roomID)
                .subscribe(onNext: { observer.onNext($0.toRoomUsers()) })
                .disposed(by: disposebag)
            return Disposables.create()
        }
    }
    
    func leave(roomID: String) {
        dataSource.leave(roomID: roomID)
    }
}
