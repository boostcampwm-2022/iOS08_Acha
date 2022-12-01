//
//  KeychainService.swift
//  Acha
//
//  Created by hong on 2022/12/02.
//

import Foundation

protocol KeychainService {
    
    /// uuid 받아 오는 메서드
    func get() -> String?
    
    /// uuid 삭제 메서드
    func delete()
    
    /// uuid 저장 메서드
    func save(uuid: String)
    
    /// uuid 업데이트 메서드
    func update(uuid: String)
}
