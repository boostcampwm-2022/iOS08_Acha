//
//  DIContainer.swift
//  Acha
//
//  Created by hong on 2022/12/10.
//

import Foundation

enum DIContainer {
    
    final class Container {
        private var dependencies: [DependencyKey: Any] = [:] {
            didSet {
                // UnitTest 시 DI 콘테이너에 추가, 삭제 처리가 제대로 되었는 지 확인
//                if isTesting() {
//                    print(dependencies)
//                }
            }
        }
        
        static let `default` = Container()
        
        func register(type: Any.Type, implement: Any) {
            let key = DependencyKey(type: type)
            dependencies[key] = implement
        }
        
        func resolve<T>(type: T.Type) -> T {
            // 디버그용
            // dump(dependencies)
            let key = DependencyKey(type: type)
            if let dependency = dependencies[key] as? T {
                return dependency
            } else {
                let protocolName = "\(type)".components(separatedBy: ".").last!
                fatalError("\(protocolName) 의 의존성을 해결할 수 없습니다.")
            }
        }
        
        func remove<T>(type: T.Type) {
            let key = DependencyKey(type: type)
            _ = dependencies.removeValue(forKey: key)
        }
        
        func reset() {
            dependencies.removeAll()
        }
    }
    
    @propertyWrapper
    struct Resolve<T> {
        private let type: T.Type
        private let container: Container
        
        var wrappedValue: T { container.resolve(type: type) }
        
        init(_ type: T.Type, on container: Container = .default) {
            self.type = type
            self.container = container
        }
    }
    
}
