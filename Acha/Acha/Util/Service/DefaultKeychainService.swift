//
//  DefaultKeychainService.swift
//  Acha
//
//  Created by hong on 2022/12/02.
//

import Foundation

struct DefaultKeychainService: KeychainService {
    
    func get() -> String? {
        guard let uuid = try? KeyChainManager.get() else {
            return nil
        }
        return uuid
    }
    
    func save(uuid: String) {
        try! KeyChainManager.save(id: uuid)
    }
    
    func delete() {
        try! KeyChainManager.delete()
    }
    
    func update(uuid: String) {
        try! KeyChainManager.update(id: uuid)
    }
    
}
