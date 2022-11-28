//
//  KeyChainManager.swift
//  Acha
//
//  Created by hong on 2022/11/22.
//

import Foundation
import RxSwift

struct KeyChainManager {
    
    func getUUID() -> RxSwift.Observable<String> {
        return Observable<String>.create { observer in
            do {
                let id = try KeyChainManager.get()
                observer.onNext(id)
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
    
    enum KeychainServiceError: Error {
        case notLogined
        case duplicateError
        case unKnown(OSStatus)
        case dataConvertError
        case noItem
        case saveIDError
    }

    static func get() throws -> String {
        
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "Acha" as AnyObject,
            kSecAttrAccount as String: "id" as AnyObject,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(
            query as CFDictionary,
            &result
        )

        guard status != errSecItemNotFound else {
            throw KeychainServiceError.noItem
        }
        
        guard status == errSecSuccess else { throw KeychainServiceError.unKnown(status) }
        
        guard let data = result as? Data else { throw KeychainServiceError.dataConvertError }
        
        let value = String(decoding: data, as: UTF8.self)
        
        return value
    }
    
    static func save(id: String) throws {

        guard let storeData = id.data(using: .utf8) else {
            throw KeychainServiceError.dataConvertError
        }
        
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "Acha" as AnyObject,
            kSecAttrAccount as String: "id" as AnyObject,
            kSecValueData as String: storeData as AnyObject
        ]
        
        let status = SecItemAdd(
            query as CFDictionary,
            nil
        )
        
        guard status != errSecDuplicateItem else {
            throw KeychainServiceError.duplicateError
        }
        
        guard status == errSecSuccess else {
            throw KeychainServiceError.unKnown(status)
        }
    }

    static func update(id: String) throws {

        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "Acha" as AnyObject
        ]
        
        let attributes: [String: AnyObject] = [
            kSecAttrAccount as String: "id" as AnyObject,
            kSecValueData as String: id as AnyObject
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        guard status != errSecItemNotFound else {
            throw KeychainServiceError.noItem
        }
        guard status == errSecSuccess else { throw KeychainServiceError.unKnown(status) }
    }

    static func delete() throws {

        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "Acha" as AnyObject
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess ||
                status == errSecItemNotFound else { throw KeychainServiceError.unKnown(status) }
    }

}
