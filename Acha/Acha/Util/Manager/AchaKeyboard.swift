//
//  AchaKeyboard.swift
//  Acha
//
//  Created by hong on 2022/12/11.
//

import UIKit
import RxSwift
import RxCocoa

final class AchaKeyboard {
    static let shared = AchaKeyboard()
    
    private let frame: Driver<CGRect>
    let keyboardHeight: Driver<CGFloat>
    private let disposeBag = DisposeBag()
    
    private init() {
        let keyboardWillChangeFrame = UIResponder.keyboardWillChangeFrameNotification
        let keyboardWillHide = UIResponder.keyboardWillHideNotification
        let keyboardEndUserKey = UIResponder.keyboardFrameEndUserInfoKey
        
        let defaultFrame = CGRect(
            x: 0,
            y: UIScreen.main.bounds.height,
            width: UIScreen.main.bounds.width,
            height: 0
        )
        
        let frameVariable = BehaviorRelay<CGRect>(value: defaultFrame)

        self.frame = frameVariable.asDriver().distinctUntilChanged()
        self.keyboardHeight = self.frame.map { UIScreen.main.bounds.height - $0.origin.y }
        
        // 키보드 프레임 변경
        let willChangeFrame = NotificationCenter.default.rx.notification(keyboardWillChangeFrame)
            .map { notification -> CGRect in
                let rectValue = notification.userInfo?[keyboardEndUserKey] as? NSValue
                return rectValue?.cgRectValue ?? defaultFrame
            }
        
        // 키보드가 없어짐
        let willHide = NotificationCenter.default.rx.notification(keyboardWillHide)
            .map { notification -> CGRect in
                let rectValue = notification.userInfo?[keyboardEndUserKey] as? NSValue
                return rectValue?.cgRectValue ?? defaultFrame
            }
        
        Observable.of(willChangeFrame, willHide)
            .merge()
            .bind(to: frameVariable)
            .disposed(by: disposeBag)
        
    }
}
