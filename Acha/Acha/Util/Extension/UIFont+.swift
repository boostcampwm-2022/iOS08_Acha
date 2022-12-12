//
//  UIFont+.swift
//  Acha
//
//  Created by 조승기 on 2022/11/15.
//

import UIKit

extension UIFont {
    static let largeTitle = UIFont.systemFont(ofSize: 32, weight: .bold)
    static let title = UIFont.systemFont(ofSize: 20, weight: .bold)
    static let smallTitle = UIFont.systemFont(ofSize: 17, weight: .bold)
    static let tinyTitle = UIFont.systemFont(ofSize: 15, weight: .bold)
    static let defaultTitle = UIFont.systemFont(ofSize: 17, weight: .semibold)
    
    static let largeBody = UIFont.systemFont(ofSize: 32, weight: .regular)
    static let boldBody = UIFont.systemFont(ofSize: 24, weight: .bold)
    static let body = UIFont.systemFont(ofSize: 24, weight: .regular)
    static let postBody = UIFont.systemFont(ofSize: 18, weight: .regular)
    static let commentBody = UIFont.systemFont(ofSize: 16, weight: .regular)
    static let subBody = UIFont.systemFont(ofSize: 14, weight: .regular)
    static let recordBody = UIFont.systemFont(ofSize: 12, weight: .bold)
}
