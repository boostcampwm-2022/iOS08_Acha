//
//  DefaultInGameUseCase.swift
//  Acha
//
//  Created by 조승기 on 2022/11/29.
//

import Foundation
import RxSwift

class DefaultInGameUseCase: InGameUseCase {
    private let recordRepository: RecordRepository
    private let userRepository: UserRepository
    private let mapID: Int
    
    private var disposeBag = DisposeBag()
    var inGameRecord = PublishSubject<[InGameRecord]>()
    
    init(mapID: Int,
         recordRepository: RecordRepository,
         userRepository: UserRepository
    ) {
        self.mapID = mapID
        self.recordRepository = recordRepository
        self.userRepository = userRepository
    }
    
    func fetchRecord() {
        userRepository
            .fetchUserData()
            .asObservable()
            .subscribe(onNext: { [weak self] (user: User) in
                guard let self else { return }
                print(user)
                self.recordRepository.fetchAllRecords()
                    .map { $0.filter { $0.mapID == self.mapID && $0.isCompleted && $0.userID == user.nickName } }
                    .map { records in
                        records.map { InGameRecord(id: $0.id,
                                                   time: $0.time,
                                                   userName: $0.userID,
                                                   date: $0.createdAt.convertToDateFormat(format: "yyyy-MM-dd"))
                        }.sorted { $0.date > $1.date}
                    }
                    .asObservable()
                    .bind(to: self.inGameRecord)
                    .disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
    }
    
    func fetchRanking() -> Single<[InGameRanking]> {
        recordRepository
            .fetchAllRecords()
            .map { $0.filter { $0.mapID == self.mapID && $0.isCompleted } }
            .map { records in
                records.map { InGameRanking(id: $0.id,
                                            time: $0.time,
                                            userName: $0.userID,
                                            date: $0.createdAt.convertToDateFormat(format: "yyyy-MM-dd"))
                }.sorted { $0.time < $1.time }
            }
    }
}
