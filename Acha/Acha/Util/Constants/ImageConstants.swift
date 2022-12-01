//
//  ImageConstants.swift
//  Acha
//
//  Created by hong on 2022/11/15.
//

import UIKit

struct ImageConstants {
    static let arrowPositionResetImage = UIImage(
        systemName: "location.circle",
        withConfiguration: UIImage.SymbolConfiguration(
            pointSize: 30,
            weight: .bold,
            scale: .large
        )
    )
    static let inGameMenuButtonImage = UIImage(
        systemName: "ellipsis",
        withConfiguration: UIImage.SymbolConfiguration(
            pointSize: 30,
            weight: .bold,
            scale: .large
        )
    )
    
    static func systemImageColorChange(
        color: UIColor,
        image: UIImage
    ) -> UIImage {
        return image.withTintColor(color, renderingMode: .alwaysOriginal)
    }
    
    static func authPasswordImage() -> UIImage {
        return UIImage(named: "password")!
    }
    
    static func authEmailImage() -> UIImage {
        return UIImage(named: "email")!
    }
    
    static func authNickNameImage() -> UIImage {
        return UIImage(named: "nickName") ?? UIImage()
    }    
}
