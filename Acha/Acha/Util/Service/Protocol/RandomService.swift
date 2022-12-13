//
//  RandomService.swift
//  Acha
//
//  Created by hong on 2022/12/05.
//

import Foundation

protocol RandomService {
    /// 랜덤한 16자리 숫자 만들어 주는 메서드 ( 방 번호 만들기 )
    func make() -> String
}
