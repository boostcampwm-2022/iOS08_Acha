//
//  MapRepository.swift
//  Acha
//
//  Created by 조승기 on 2022/11/27.
//

import RxSwift

protocol MapRepository {
    func fetchAllMaps() -> Single<[Map]>
    func fetchMapsAtLocation(location: String) -> Single<[Map]>
}
