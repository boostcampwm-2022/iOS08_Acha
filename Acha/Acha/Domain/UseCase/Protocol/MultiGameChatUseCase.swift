//
//  MultiGameChatUseCase.swift
//  Acha
//
//  Created by hong on 2022/12/08.
//

import Foundation
import RxSwift

protocol MultiGameChatUseCase {
    func chatWrite(text: String)
    func chatUpdate(roomID: String)
    func observeChats(roomID: String) -> Observable<[Chat]>
    func leave(roomID: String)
}
