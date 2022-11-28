//
//  MapRepository.swift
//  Acha
//
//  Created by 조승기 on 2022/11/27.
//

import Foundation
import RxSwift

protocol MapRepository {
    func fetchAllMaps() -> Observable<[Map]>
}
