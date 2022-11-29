//
//  InGameRankingViewModel.swift
//  Acha
//
//  Created by 조승기 on 2022/11/21.
//

import Foundation
import RxSwift
import Firebase

class InGameRankingViewModel: BaseViewModel {
    struct Input {
        
    }
    struct Output {
        var rankings: Single<[InGameRanking]>
    }
    let map: Map
    var disposeBag = DisposeBag()
    let ref: DatabaseReference!
    
    init(map: Map) {
        self.map = map
        self.ref = Database.database().reference()
    }
    
    func transform(input: Input) -> Output {
        Output(rankings: fetchData())
    }
    
    private func fetchData() -> Single<[InGameRanking]> {
        return Single.create { [weak self] single in
//            guard let self else { return Disposables.create() }
//            self.ref.child("record").observeSingleEvent(of: .value,
//                                                        with: { snapshot in
//                guard let snapData = snapshot.value as? [Any],
//                      let data = try? JSONSerialization.data(withJSONObject: snapData),
//                      let records = try? JSONDecoder().decode([Record].self, from: data),
//                      let mapRank = self.map.records
//                else {
//                    print(Errors.decodeError)
//                    return
//                }
//                
//                let inGameRanking = records.enumerated()
//                    .filter { mapRank.contains($0.element.id) }
//                    .map { InGameRanking(time: $1.time,
//                                        userName: $1.userID,
//                                        date: $1.createdAt.convertToDateFormat(format: "yyyy-MM-dd"))}
//                    .sorted(by: { $0.time < $1.time })
//                
//                single(.success(inGameRanking))
//                return
//            })
            return Disposables.create()
        }
    }
}
