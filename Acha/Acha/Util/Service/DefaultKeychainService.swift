//
//  DefaultKeychainService.swift
//  Acha
//
//  Created by hong on 2022/12/02.
//
import Foundation
import RxSwift

struct DefaultKeychainService: KeychainService {

    func get() -> String? {
        return try? KeyChainManager.get()
    }

    func save(uuid: String) {
        try? KeyChainManager.save(id: uuid)
    }

    func delete() {
        try? KeyChainManager.delete()
    }

    func update(uuid: String) {
        try? KeyChainManager.update(id: uuid)
    }

}
