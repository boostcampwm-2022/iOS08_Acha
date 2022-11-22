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
        var inGameRecord: PublishRelay<[InGameRecord]> = PublishRelay()
    }
    
    var disposeBag = DisposeBag()
    let map: Map
    private let ref: DatabaseReference!
    
    init(map: Map) {
        self.map = map
        self.ref = Database.database().reference()
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        return Output()
    }
    
}
