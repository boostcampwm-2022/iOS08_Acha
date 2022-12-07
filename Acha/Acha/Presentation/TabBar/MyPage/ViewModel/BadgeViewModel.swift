//
//  BadgeViewModel.swift
//  Acha
//
//  Created by 조승기 on 2022/11/30.
//

import Foundation
import RxSwift

class BadgeViewModel: BaseViewModel {
    struct Input {
        
    }
    
    struct Output {
        var brandNewBadges = BehaviorSubject<[Badge]>(value: [])
        var aquiredBadges = BehaviorSubject<[Badge]>(value: [])
        var inaquiredBadges = BehaviorSubject<[Badge]>(value: [])
    }
    var disposeBag = DisposeBag()
    let allBadges: [Badge]
    let ownedBadges: [Badge]
    
    init(allBadges: [Badge],
         ownedBadges: [Badge]
    ) {
        self.allBadges = allBadges
        self.ownedBadges = ownedBadges
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        output.brandNewBadges
            .onNext(ownedBadges)
        output.aquiredBadges
            .onNext(allBadges.filter { $0.isOwn })
        output.inaquiredBadges
            .onNext(allBadges.filter { !$0.isOwn })
        return output
    }
}
