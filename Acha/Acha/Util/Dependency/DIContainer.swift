//
//  DIContainer.swift
//  Acha
//
//  Created by hong on 2022/12/10.
//

import Foundation

enum Dependencies {
    
    struct Name: Equatable {
        let value: String
        static let `default` = Name(value: "default")
        static func == (lhs: Name, rhs: Name) -> Bool { lhs.value == rhs.value }
    }
    
    final class Container {
        private var dependencies: [(key: Dependencies.Name, value: Any)] = [] {
            didSet {
                // UnitTest 시 DI 콘테이너에 추가, 삭제 처리가 제대로 되었는 지 확인
//                if isTesting() {
//                    print(dependencies)
//                }
            }
        }
        
        static let `default` = Container()
        
        func register(key: Dependencies.Name = .default, dependency: Any) {
            dependencies.append((key: key, value: dependency))
        }
        
        func resolve<T>(key: Dependencies.Name = .default) -> T {
            // 디버그용
            // dump(dependencies)
            
            let instanceObjectValue = dependencies
                .first { dependency in
                    dependency.key == key && dependency.value is T
                }
                .flatMap { (_, value) in
                    value
                }
            
            guard let instance = instanceObjectValue as? T else {
                fatalError("기대 값으로 타입 캐스팅할 수 없습니다")
            }
            
            return instance
        }
        
        func remove(key: Dependencies.Name = .default) {
            dependencies.removeAll(where: { $0.key == key })
        }
        
        func reset() {
            dependencies.removeAll()
        }
    }
    
    @propertyWrapper
    struct Inject<T> {
        private let dependencyName: Name
        private let container: Container
        
        var wrappedValue: T { container.resolve(key: dependencyName) }
        
        init(_ dependencyName: Name, on container: Container) {
            self.dependencyName = dependencyName
            self.container = container
        }
    }
    
}
