//
//  KeyboardManager.swift
//  Acha
//
//  Created by hong on 2022/11/21.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class KeyboardManager {
    static let shared = KeyboardManager()
    private init() {}
    
    static let keyboardWillShow = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
    static let keyboardWillHide = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
    static var disposeBag = DisposeBag()
    
    static func keyboardWillShow(view: UIView, superView: UIView? = nil) {
        
        if let superView = superView {
            keyboardWillShow
                .compactMap { $0.userInfo }
                .map { userInfo -> CGFloat in
                    return (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
                }
                .subscribe(onNext: { height in
                    view.snp.updateConstraints {
                        $0.bottom.equalTo(superView.safeAreaLayoutGuide).offset(-height+view.frame.height-12)
                    }
                })
                .disposed(by: disposeBag)
        } else {
            keyboardWillShow
                .compactMap { $0.userInfo }
                .map { userInfo -> CGFloat in
                    return (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
                }
                .subscribe(onNext: { height in
                    view.snp.updateConstraints {
                        $0.bottom.equalToSuperview().offset(-height)
                    }
                })
                .disposed(by: disposeBag)
        }

    }
    
    static func keyboardWillHide(view: UIView, superView: UIView? = nil) {
        
        if let superView = superView {
            keyboardWillHide
                .subscribe { _ in
                    view.snp.updateConstraints {
                        $0.bottom.equalTo(superView.safeAreaLayoutGuide)
                    }
                }
                .disposed(by: disposeBag)
        } else {
            keyboardWillHide
                .subscribe { _ in
                    view.snp.updateConstraints {
                        $0.bottom.equalToSuperview()
                    }
                }
                .disposed(by: disposeBag)
        }

    }
}
