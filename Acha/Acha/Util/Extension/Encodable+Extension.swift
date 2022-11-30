//
//  Encodable+Extension.swift
//  Acha
//
//  Created by hong on 2022/11/22.
//

import Foundation

// MARK: - struct > Dictonary 변환 코드
extension Encodable {
    subscript(key: String) -> Any? {
        return dictionary[key]
    }
    var dictionary: [String: Any] {
        return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
    }
}
