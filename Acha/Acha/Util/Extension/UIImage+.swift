//
//  UIImage+Extension.swift
//  Acha
//
//  Created by hong on 2022/11/22.
//

import UIKit

extension UIImage {
    // MARK: - Asset
    static let noBadge = UIImage(named: "noBadge")!
    static let xImage = UIImage(named: "x.circle.fill")!
    static let penguinImage = UIImage(named: "penguin")!
    static let commentImage: UIImage = UIImage(named: "commentImage")!
    
    static let authEmailImage: UIImage = UIImage(named: "email")!
    static let authNickNameImage: UIImage = UIImage(named: "nickName")!
    static let authPasswordImage: UIImage = UIImage(named: "password")!
    static let authInvalidateImage: UIImage = UIImage(named: "invalidate")!
    
    static let firstAnnotation = UIImage(named: "firstAnnotation")!
    static let secondAnnotation = UIImage(named: "secondAnnotation")!
    static let thirdAnnotation = UIImage(named: "thirdAnnotation")!
    static let fourthAnnotation = UIImage(named: "fourthAnnotation")!
    
    // MARK: - System
    static let ellipsisImage: UIImage = UIImage(systemName: "ellipsis")!
        .withTintColor(.pointDark, renderingMode: .alwaysOriginal)
    static let plusImage: UIImage = UIImage(systemName: "plus")!
    static let systemEyeCircle = UIImage(systemName: "eye.circle",
                                         withConfiguration: UIImage.SymbolConfiguration(
                                            pointSize: 30,
                                            weight: .bold,
                                            scale: .large))
    static let arrowPositionResetImage = UIImage(systemName: "location.circle",
                                                 withConfiguration: UIImage.SymbolConfiguration(
                                                    pointSize: 30,
                                                    weight: .bold,
                                                    scale: .large))
    static let multiplyImage: UIImage = UIImage(systemName: "multiply",
                                                withConfiguration: UIImage.SymbolConfiguration(
                                                   pointSize: 30,
                                                   weight: .bold,
                                                   scale: .large))!
           .withTintColor(.black,
                          renderingMode: .alwaysOriginal)
    static let houseImage: UIImage = UIImage(systemName: "house",
                                             withConfiguration: UIImage.SymbolConfiguration(
                                                pointSize: 30,
                                                weight: .bold,
                                                scale: .large))!
        .withTintColor(.white,
                       renderingMode: .alwaysOriginal)
    static let magnifyingglassImage: UIImage = UIImage(systemName: "magnifyingglass",
                                                       withConfiguration: UIImage.SymbolConfiguration(
                                                          pointSize: 30,
                                                          weight: .bold,
                                                          scale: .large))!
        .withTintColor(.white,
                       renderingMode: .alwaysOriginal)
    
    static let inGameMenuButtonImage = UIImage(
        systemName: "ellipsis",
        withConfiguration: UIImage.SymbolConfiguration(
            pointSize: 30,
            weight: .bold,
            scale: .large
        )
    )
    
    func imageWith(newSize: CGSize) -> UIImage {
        let image = UIGraphicsImageRenderer(size: newSize).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
            
        return image.withRenderingMode(renderingMode)
    }
    
    func resize(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale

        let size = CGSize(width: newWidth, height: newHeight)
        let render = UIGraphicsImageRenderer(size: size)
        let renderImage = render.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        
        return renderImage
    }
}
