//
//  UIViewController+.swift
//  Acha
//
//  Created by 조승기 on 2022/11/21.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    /// 액션 핸들러를 포함한 버튼, 취소 버튼을 포함하는 핸들러
    func showAlert(
        title: String,
        message: String,
        actionTitle: String,
        actionHandler: @escaping (() -> Void)
    ) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        let action = UIAlertAction(title: actionTitle, style: .default, handler: { _ in
            actionHandler()
        })
        alert.addAction(cancelAction)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    /// 액션 핸들러 + 취소 핸들러
    func showAlert(
        title: String,
        message: String,
        actionTitle: String,
        actionHandler: @escaping (() -> Void),
        cancelHandler: @escaping (() -> Void)
    ) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: { _ in
            cancelHandler()
        })
        let action = UIAlertAction(title: actionTitle, style: .default, handler: { _ in
            actionHandler()
        })
        alert.addAction(cancelAction)
        alert.addAction(action)
        present(alert, animated: true)
    }
}
