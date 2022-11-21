//
//  TabBarType.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import Foundation

enum TabBarType: CaseIterable {
    case home
    case record
    case community
    case myPage
    
    var pageNumber: Int {
        switch self {
        case .home:
            return 0
        case .record:
            return 1
        case .community:
            return 2
        case .myPage:
            return 3
        }
    }
    
    var pageTitle: String {
        switch self {
        case .home:
            return "땅따먹기"
        case .record:
            return "기록"
        case .community:
            return "커뮤니티"
        case .myPage:
            return "마이페이지"
        }
    }
    
    var iconImage: String {
        switch self {
        case .home:
            return "house"
        case .record:
            return "list.clipboard"
        case .community:
            return "person.2"
        case .myPage:
            return "face.smiling"
        }
    }
    
    var selectedIconImage: String {
        switch self {
        case .home:
            return "house.fill"
        case .record:
            return "list.clipboard.fill"
        case .community:
            return "person.2.fill"
        case .myPage:
            return "face.smiling.inverse"
        }
    }
}
