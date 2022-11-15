//
//  UIButton+.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/15.
//

import UIKit

extension UIButton {
    
    func isEnabled(_ enabled: Bool) {
        self.isEnabled = enabled
        self.alpha = enabled ? 1.0 : 0.5
    }
    
}
