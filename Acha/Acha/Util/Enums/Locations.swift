//
//  Locations.swift
//  Acha
//
//  Created by 배남석 on 2022/11/24.
//

import Foundation

enum Locations: CaseIterable {
    case seoul
    case incheon
    case gyeonggi
    case busan
    case gyeongbuk
    case gyeongnam
    case chungbuk
    case chungnam
    
    var string: String {
        switch self {
        case .seoul:
            return "서울"
        case .incheon:
            return "인천"
        case .gyeonggi:
            return "경기"
        case .busan:
            return "부산"
        case .gyeongbuk:
            return "경북"
        case .gyeongnam:
            return "경남"
        case .chungbuk:
            return "충북"
        case .chungnam:
            return "충남"
        }
    }
}
