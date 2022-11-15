//
//  Errors.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/14.
//

import Foundation

enum Errors {
    case decodeError
    case cannotDrawPolyLine
    
    var description: String {
        switch self {
        case .decodeError:
            return "decoding에 실패했습니다."
        case .cannotDrawPolyLine:
            return "땅의 경계선(PolyLine)을 그릴 수 없습니다."
        }
    }
}
