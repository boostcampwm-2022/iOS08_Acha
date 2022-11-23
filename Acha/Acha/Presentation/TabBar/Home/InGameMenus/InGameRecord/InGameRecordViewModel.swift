//
//  InGameRecordViewModel.swift
//  Acha
//
//  Created by 조승기 on 2022/11/21.
//

import Foundation
import RxSwift
import RxRelay
import Firebase

final class InGameRecordViewModel: BaseViewModel {
    
    struct Input {
        
    }
    
    struct Output {
        var inGameRecord: Single<[InGameRecord]>
    }
    
    var disposeBag = DisposeBag()
    let mapID: Int
    private let ref: DatabaseReference!
    
    init(mapID: Int) {
        self.mapID = mapID
        self.ref = Database.database().reference()
    }
    
    func transform(input: Input) -> Output {
        Output(inGameRecord: fetchData())
    }
    
    private func fetchData() -> Single<[InGameRecord]> {
        return Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            self.ref.child("record").observeSingleEvent(of: .value,
                                                        with: { snapshot in
                guard let snapData = snapshot.value as? [Any],
                      let data = try? JSONSerialization.data(withJSONObject: snapData),
                      let records = try? JSONDecoder().decode([Record].self, from: data)
                else {
                    print(Errors.decodeError)
                    return
                }
                
                #warning("나의 기록만 가져오게 AND 연산을 한번 더 수행해야함!")
                let inGameRecord = records
                    .filter { $0.mapID == self.mapID }
                    .map { InGameRecord(time: $0.time,
                                        userName: $0.userID,
                                        date: $0.createdAt.convertToDateFormat(format: "yyyy-MM-dd"))}
                    .sorted(by: { $0.date < $1.date})
                
                single(.success(inGameRecord))
                return
            })
            return Disposables.create()
        }
    }
}
