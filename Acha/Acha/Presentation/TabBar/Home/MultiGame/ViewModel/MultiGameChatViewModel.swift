//
//  MultiGameChatViewModel.swift
//  Acha
//
//  Created by hong on 2022/12/08.
//

import Foundation
import RxSwift

final class MultiGameChatViewModel: BaseViewModel {
    
    struct Input {
        let viewDidAppear: Observable<Void>
        let commentButtonTapped: Observable<Void>
        let textInput: Observable<String>
    }
    struct Output {
        
    }
    var disposeBag: RxSwift.DisposeBag = .init()
    
    private let roomID: String
    private let useCase: MultiGameChatUseCase
    
    init(roomID: String, useCase: MultiGameChatUseCase) {
        self.roomID = roomID
        self.useCase = useCase
    }
    
    func transform(input: Input) -> Output {
        return Output()
    }
}
