//
//  CALayer+Extension.swift
//  Acha
//
//  Created by hong on 2022/11/15.
//

import UIKit

extension CALayer {
    func addBorder(
        directions: [UIRectEdge],
        color: UIColor,
        width: CGFloat
    ) {
        for direction in directions {
            let border = CALayer()
            switch direction {
            case .top:
                border.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: width)
            case .bottom:
                border.frame = CGRect.init(x: 0, y: frame.height - width, width: frame.width, height: width)
            case .left:
                border.frame = CGRect.init(x: 0, y: 0, width: width, height: frame.height)
            case .right:
                border.frame = CGRect.init(x: frame.width - width, y: 0, width: width, height: frame.height)
            default:
                break
            }
            border.backgroundColor = color.cgColor
            self.addSublayer(border)
        }
    }
}
