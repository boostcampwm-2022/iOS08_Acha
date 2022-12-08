//
//  MultiGameChatViewModel.swift
//  Acha
//
//  Created by hong on 2022/12/08.
//

import Foundation
import RxSwift
import RxCocoa

final class MultiGameChatViewModel: BaseViewModel {
    
    struct Input {
        let viewDidAppear: Observable<Void>
        let commentButtonTapped: Observable<Void>
        let textInput: Observable<String>
    }
    struct Output {
        let chatFetched: Driver<[Chat]>
        let chatDelievered: Driver<Void>
    }
    var disposeBag: RxSwift.DisposeBag = .init()
    
    private let roomID: String
    private let useCase: MultiGameChatUseCase
    
    init(roomID: String, useCase: MultiGameChatUseCase) {
        self.roomID = roomID
        self.useCase = useCase
    }
    
    func transform(input: Input) -> Output {
        
        let chatFetched = PublishSubject<[Chat]>()
        let chatDelievered = PublishSubject<Void>()
        
        input.viewDidAppear
            .withUnretained(self)
            .subscribe { _ in
                self.useCase.observeChats(roomID: self.roomID)
                    .subscribe { chats in
                        chatFetched.onNext(chats)
                    }
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
        
        input.textInput
            .subscribe { [weak self] texts in
                self?.useCase.chatWrite(text: texts)
            }
            .disposed(by: disposeBag)
        
        input.commentButtonTapped
            .withUnretained(self)
            .subscribe { _ in
                self.useCase.chatUpdate(roomID: self.roomID)
                chatDelievered.onNext(())
            }
            .disposed(by: disposeBag)
        
        return Output(chatFetched: chatFetched.asDriver(onErrorJustReturn: []),
                      chatDelievered: chatDelievered.asDriver(onErrorJustReturn: ()))
    }
}
