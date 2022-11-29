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
    let mapID: Int
    var disposeBag = DisposeBag()
    let ref: DatabaseReference!
    
    init(mapID: Int) {
        self.mapID = mapID
        self.ref = Database.database().reference()
    }
    
    func transform(input: Input) -> Output {
        Output(rankings: fetchData())
    }
    
    private func fetchData() -> Single<[InGameRanking]> {
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
                
                let inGameRanking = records
                    .filter { $0.mapID == self.mapID && $0.isCompleted }
                    .map { InGameRanking(time: $0.time,
                                        userName: $0.userID,
                                        date: $0.createdAt.convertToDateFormat(format: "yyyy-MM-dd"))}
                    .sorted(by: { $0.time < $1.time })
                
                single(.success(inGameRanking))
                return
            })
            return Disposables.create()
        }
    }
}
