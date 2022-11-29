//
//  SelectMapUseCase.swift
//  Acha
//
//  Created by 조승기 on 2022/11/27.
//

import RxSwift

protocol SelectMapUseCase: MapBaseUseCase {
    var selectedMap: Map? { get set }
    
    func start()
    func getMapsInUpdatedRegion(region: MapRegion) -> [Map]
    func mapSelected(_ selectedMap: Map) -> Single<(String, [Record])>
    func isStartable() -> Bool
}
