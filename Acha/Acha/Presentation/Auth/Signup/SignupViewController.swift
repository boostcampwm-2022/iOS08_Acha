//
//  SignupViewController.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class SignupViewController: ScrollAbleViewController {
    
    private let titleView = AuthTitleView(image: nil, text: "회원가입")
    private let emailTextField = AuthInputTextField(type: .email)
    private let passwordTextField = AuthInputTextField(type: .password)
    private let nickNameTextField = AuthInputTextField(type: .nickName)
    private let signUpButton = AuthButton(color: .pointDark, text: "회원가입")
    private let logInButton = AuthButton(color: .pointDark, text: "로그인")
    
    private let viewModel: SignUpViewModel
    private var disposeBag = DisposeBag()
    
    init(viewModel: SignUpViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        bind()
    }

    func bind() {
        
        let inputs = SignUpViewModel.Input(
            passwordUpdated: passwordTextField.rx.text.orEmpty.asObservable(),
            nickNameUpdated: nickNameTextField.rx.text.orEmpty.asObservable(),
            emailUpdated: emailTextField.rx.text.orEmpty.asObservable(),
            signUpButtonDidTap: signUpButton.rx.tap.asObservable(),
            logInButtonDidTap: logInButton.rx.tap.asObservable()
        )
        
        let outputs = viewModel.transform(input: inputs)
        outputs.passwordValidated
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] result in
                self?.passwordTextField.validateUpdate(result)
            })
            .disposed(by: disposeBag)

        outputs.emailValidated
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] result in
                self?.emailTextField.validateUpdate(result)
            })
            .disposed(by: disposeBag)
        
        outputs.nickNameValidated
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] result in
                self?.nickNameTextField.validateUpdate(result)
            })
            .disposed(by: disposeBag)
        
        outputs.signUpSuccesssed
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] result in
                if !result {
                    self?.alertSignUpFailed()
                }
            })
            .disposed(by: disposeBag)

        KeyboardManager.keyboardWillHide(view: contentView)
        KeyboardManager.keyboardWillShow(view: contentView)
        emailTextField.rx.controlEvent([.editingDidEndOnExit])
            .subscribe { [weak self] _ in
                self?.passwordTextField.becomeFirstResponder()
            }
            .disposed(by: disposeBag)

        passwordTextField.rx.controlEvent([.editingDidEndOnExit])
            .subscribe { [weak self] _ in
                self?.nickNameTextField.becomeFirstResponder()
            }
            .disposed(by: disposeBag)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureContentView()
    }
    
    private func alertSignUpFailed() {
        let alertController = UIAlertController(title: "경고",
                                                message: "회원가입에 실패하셨습니다.",
                                                preferredStyle: .alert)
        let alert = UIAlertAction(title: "예", style: .cancel)
        alertController.addAction(alert)
        present(alertController, animated: true)
    }
}

extension SignupViewController {

    private func configureContentView() {
        contentView.addArrangedSubview(titleView)
        contentView.addArrangedSubview(emailTextField)
        contentView.addArrangedSubview(passwordTextField)
        contentView.addArrangedSubview(nickNameTextField)
        contentView.addArrangedSubview(signUpButton)
        contentView.addArrangedSubview(logInButton)
        
        titleView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top).inset(70)
        }
        
        emailTextField.snp.makeConstraints {
            $0.height.equalTo(60)
            $0.leading.trailing.equalTo(contentView).inset(70)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.height.equalTo(60)
            $0.leading.equalTo(contentView.snp.leading).inset(70)
            $0.leading.trailing.equalTo(contentView).inset(70)
        }
        
        nickNameTextField.snp.makeConstraints {
            $0.height.equalTo(60)
            $0.leading.trailing.equalTo(contentView).inset(70)
        }
        
        signUpButton.snp.makeConstraints {
            $0.height.equalTo(60)
            $0.leading.trailing.equalTo(contentView).inset(70)
        }
        
        logInButton.snp.makeConstraints {
            $0.height.equalTo(60)
            $0.leading.trailing.equalTo(contentView).inset(70)
        }
        
    }

}
