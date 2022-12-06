//
//  MultiGameViewModel.swift
//  Acha
//
//  Created by hong on 2022/12/06.
//

import Foundation

struct MultiGameViewModel {
    
    private let roomId: String
    private let useCase: MultiGameUseCase
    private weak var coordinator: MultiGameCoordinator?
    init
    (
        coordinator: MultiGameCoordinator,
        useCase: MultiGameUseCase,
        roomId: String
    ) {
        self.roomId = roomId
        self.useCase = useCase
        self.coordinator = coordinator
    }
}
