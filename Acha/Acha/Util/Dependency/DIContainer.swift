//
//  DIContainer.swift
//  Acha
//
//  Created by hong on 2022/12/10.
//

import Foundation

enum DIContainer {
    
    @propertyWrapper
    struct Resolve<T> {
        private let type: T.Type
        private let container = DependenciesContainer.shared
        
        var wrappedValue: T { container.resolve(type) }
        
        init(_ type: T.Type) {
            self.type = type
        }
    }
    
}
