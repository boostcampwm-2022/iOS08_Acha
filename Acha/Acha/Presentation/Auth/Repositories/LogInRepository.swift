//
//  LogInRepository.swift
//  Acha
//
//  Created by hong on 2022/11/27.
//

import Foundation
import RxSwift

protocol LogInRepositoryProtocol {
    func logIn(data: LoginData) -> Observable<String>
}

struct LogInRepository: LogInRepositoryProtocol {
    
    private let provider: LoginAble
    
    init(provider: LoginAble) {
        self.provider = provider
    }
    
    func logIn(data: LoginData) -> Observable<String> {
        return provider.logIn(data: data)
    }
}
