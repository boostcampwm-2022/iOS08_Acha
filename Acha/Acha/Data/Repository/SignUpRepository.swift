//
//  SignUpRepository.swift
//  Acha
//
//  Created by hong on 2022/11/27.
//

import Foundation
import RxSwift

protocol SignUpRepositoryProtocol {
    func signUp(data: SignUpData) -> Observable<String>
}

struct SignUpRepository: SignUpRepositoryProtocol {
    
    private let provider: SignUpAble
    
    init(provider: SignUpAble) {
        self.provider = provider
    }
    
    func signUp(data: SignUpData) -> Observable<String> {
        return provider.signUp(data: data)
    }
    
}
