//
//  LoginViewController.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit
import SnapKit
import RxSwift

final class LoginViewController: UIViewController {
    
    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIStackView()
    
    private lazy var titleView = AuthTitleView(image: nil, text: "로그인")
    private lazy var emailTextField = AuthInputTextField(type: .email)
    private lazy var passwordTextField = AuthInputTextField(type: .password)
    private lazy var loginButton = AuthButton(color: .pointLight, text: "로그인")
    private lazy var toSignUpButton = AuthButton(color: .pointLight, text: "회원가입")
    
    private let viewModel: LoginViewModel
    private var disposeBag = DisposeBag()
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = "로그인"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureStackView()
        layout()
        hideKeyboardWhenTapped()
        bind()
        resignBind()
        
    }
    
    private func configureStackView() {
        contentView.axis = .vertical
        contentView.spacing = 50
        contentView.backgroundColor = .white
        contentView.distribution = .fillProportionally
    }
}

extension LoginViewController {
    
    private func layout() {        
        addViews()
        addConstraints()
    }
    
    private func addViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addArrangedSubview(titleView)
        contentView.addArrangedSubview(emailTextField)
        contentView.addArrangedSubview(passwordTextField)
        contentView.addArrangedSubview(loginButton)
        contentView.addArrangedSubview(toSignUpButton)
    }
    
    private func addConstraints() {
        
        scrollView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(80)
        }

        contentView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.centerX.top.bottom.equalToSuperview()
        }
        
        titleView.snp.makeConstraints {
            $0.height.equalTo(80)
        }
        
        emailTextField.snp.makeConstraints {
            $0.height.equalTo(60)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.height.equalTo(60)

        }
        
        loginButton.snp.makeConstraints {
            $0.height.equalTo(60)
        }
        
        toSignUpButton.snp.makeConstraints {
            $0.height.equalTo(60)
        }
    }
    
}

extension LoginViewController {
    func bind() {
        AchaKeyboard.shared.keyboardHeight
            .drive(onNext: { [weak self] keyboardHeight in
                guard let self = self else {return}
                self.contentView.snp.updateConstraints {
                    $0.bottom.equalToSuperview().offset(-keyboardHeight)
                }
            })
            .disposed(by: disposeBag)

        let inputs = LoginViewModel.Input(
            emailUpdated: emailTextField.rx.text.orEmpty.asObservable(),
            passwordUpdated: passwordTextField.rx.text.orEmpty.asObservable(),
            loginButtonDidTap: loginButton.rx.tap.asObservable(),
            signUpButtonDidTap: toSignUpButton.rx.tap.asObservable()
        )
        
        let outputs = viewModel.transform(input: inputs)
        outputs.emailValidate
            .subscribe { [weak self] emailValidation in
                self?.emailTextField.validateUpdate(emailValidation)
            }
            .disposed(by: disposeBag)
        
        outputs.passwordValidate
            .subscribe { [weak self] passwordValidatiaon in
                self?.passwordTextField.validateUpdate(passwordValidatiaon)
            }
            .disposed(by: disposeBag)
        
        outputs.loginResult
            .subscribe(onNext: { [weak self] _ in
                self?.alertLoginFailed()
            })
            .disposed(by: disposeBag)
    }
    
    private func alertLoginFailed() {
        let alertController = UIAlertController(title: "경고",
                                                message: "로그인에 실패하셨습니다.",
                                                preferredStyle: .alert)
        let alert = UIAlertAction(title: "예", style: .cancel)
        alertController.addAction(alert)
        present(alertController, animated: true)
    }
    
    private func resignBind() {
        emailTextField.rx.controlEvent([.editingDidEndOnExit])
            .subscribe { [weak self] _ in
                self?.passwordTextField.becomeFirstResponder()
            }
            .disposed(by: disposeBag)
    }
}

extension LoginViewController {
    private func hideKeyboardWhenTapped() {
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
