//
//  LoginViewController.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit
import SnapKit

final class LoginViewController: UIViewController {
    
    private let emailTextField = AuthInputTextField(type: .email)
    private let passwordTextField = AuthInputTextField(type: .password)
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple
        
        layout()
    }
}

extension LoginViewController {
    
    private func layout() {
        
    }
    
    private func addViews() {
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
    }
    
    private func addConstraints() {
        
    }
    
}
