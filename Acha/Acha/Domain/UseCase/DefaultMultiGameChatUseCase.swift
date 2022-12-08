//
//  DefaultMultiGameChatUseCase.swift
//  Acha
//
//  Created by hong on 2022/12/08.
//

import Foundation
import RxSwift
import RxRelay

final class DefaultMultiGameChatUseCase: MultiGameChatUseCase {
    
    private var chats = ""
    private let disposeBag = DisposeBag()
    
    private let roomRepository: GameRoomRepository
    private let userRepository: UserRepository
    
    init(
        roomRepository: GameRoomRepository,
        userRepository: UserRepository
    ) {
        self.roomRepository = roomRepository
        self.userRepository = userRepository
    }
    
    func chatWrite(text: String) {
        chats = text
    }
    
    func chatUpdate(roomID: String) {
        userRepository.fetchUserData()
            .subscribe(onSuccess: { [weak self] user in
                
                guard let chat = self?.chats,
                chat.count != 0 else { return }
                
                let newChat = Chat(
                    id: user.id,
                    nickName: user.nickName,
                    created: Date(),
                    text: chat
                )
                self?.roomRepository.updateChats(
                    roomID: roomID,
                    chat: newChat
                )
            })
            .disposed(by: disposeBag)
    }
    
    func observeChats(roomID: String) -> Observable<[Chat]> {
        return roomRepository.observingChats(id: roomID)
            .map { [weak self] chatDTOs in
                let chattings = chatDTOs.map { $0.toChat() }
                let reads = chatDTOs.map { $0.toRead() }
                self?.readsUpdate(roomID: roomID, reads: reads)
                return chattings
            }
    }
    
    func leave(roomID: String) {
        roomRepository.removeObserverRoom(id: roomID)
        roomRepository.leaveRoom(id: roomID)
    }
    
    private func readsUpdate(roomID: String, reads: [[String]]) {
        guard let uuid = userRepository.getUUID() else {return}
        var reads = reads
        for index in 0..<reads.count {
            var read = reads[index]
            if !read.contains(uuid) {
                read.append(uuid)
                reads[index] = read
            }
        }
        roomRepository.updateReads(roomID: roomID, reads: reads)
    }
    
}
