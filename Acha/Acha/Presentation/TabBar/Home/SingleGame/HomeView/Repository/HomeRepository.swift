//
//  HomeRepository.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import Foundation
import RxSwift

protocol UUIDProvider {
    func getUUID() -> Observable<String>
}

protocol HomeRepositoryProtocol {
    func getUUID() -> Observable<String>
}

struct HomeRepository: HomeRepositoryProtocol {
 
    private let provier: UUIDProvider
    init(provider: UUIDProvider) {
        self.provier = provider
    }
    
    func getUUID() -> RxSwift.Observable<String> {
        return provier.getUUID()
    }
    
}
