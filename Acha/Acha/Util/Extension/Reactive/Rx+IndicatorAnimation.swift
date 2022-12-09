//
//  Rx+IndicatorAnimation.swift
//  Acha
//
//  Created by hong on 2022/12/09.
//

import UIKit
import RxSwift
import Then

extension Reactive where Base: UIView {
    
    var indicator: Binder<Bool> {
        Binder(base) { base, indicator in
            
            if indicator {
                let image = UIButton().then {
                    $0.center = base.center
                    $0.layer.borderColor = UIColor.black.cgColor
                    $0.layer.borderWidth = 4
                    $0.layer.cornerRadius = 10
                    $0.frame.size = CGSize(width: 50, height: 50)
                    $0.tag = 444
                }
                base.addSubview(image)
                image.layer.add(animationGroup, forKey: nil)
            } else {
                base.subviews.forEach { if $0 is UIButton,
                                           $0.tag == 444 { $0.removeFromSuperview() } }
            }
        }
    }
    
    var animationGroup: CAAnimationGroup {
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 0.7
        animationGroup.fillMode = CAMediaTimingFillMode.forwards
        animationGroup.repeatCount = .infinity
        
        let animation3 = CABasicAnimation(keyPath: "position.x")
        animation3.fromValue = base.center.x-100
        animation3.toValue = base.center.x + 100
        
        let animation5 = CABasicAnimation(keyPath: "transform.rotation.x")
        animation5.fromValue = 0
        animation5.toValue = Double.pi / 3
        
        animationGroup.animations = [animation3, animation5]
        
        return animationGroup
    }
}
