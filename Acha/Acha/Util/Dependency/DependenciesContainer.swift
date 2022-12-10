//
//  DependenciesContainer.swift
//  Acha
//
//  Created by hong on 2022/12/10.
//

import Foundation

final class DependenciesContainer {
    static let shared = DependenciesContainer()
    private init () {}
    
    // DependencyKey 클래스를 이용해서 형과 이름을 사용해서 분류
    private var dependencies: [DependencyKey: Any] = [:]
    
    func register<T>(
        _ type: T.Type,
        implement: Any,
        name: String? = nil
    ) {
        let dependencyKey = DependencyKey(type: type, name: name)
        dependencies[dependencyKey] = implement
    }
    
    func resolve<T>(
        _ type: T.Type,
        name: String? = nil
    ) -> T {
        let dependencyKey = DependencyKey(type: type, name: name)
        if let dependency = dependencies[dependencyKey] as? T {
            return dependency
        } else {
            let protocolName = "\(type)".components(separatedBy: ".").last!
            fatalError("\(protocolName) 의 의존성을 해결할 수 없습니다.")
        }
    }
    
}

final class DependencyKey: Hashable, Equatable {
    
    private let type: Any.Type
    private let name: String?
    
    init(type: Any.Type, name: String? = nil) {
        self.type = type
        self.name = name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(type))
        hasher.combine(name)
    }
    
    static func == (lhs: DependencyKey, rhs: DependencyKey) -> Bool {
        return lhs.type == rhs.type && lhs.name == rhs.name
    }
}
