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

final class SignupViewController: UIViewController {
    
    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIStackView()
    
    private lazy var titleView = AuthTitleView(image: nil, text: "회원가입")
    private lazy var emailTextField = AuthInputTextField(type: .email)
    private lazy var passwordTextField = AuthInputTextField(type: .password)
    private lazy var nickNameTextField = AuthInputTextField(type: .nickName)
    private lazy var signUpButton = AuthButton(color: .pointDark, text: "회원가입")
    private lazy var logInButton = AuthButton(color: .pointDark, text: "로그인")
    
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
        hideKeyboardWhenTapped()
        configureStackView()
        configureUI()
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
        
        outputs.signUpFailed
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] result in
                if !result {
                    self?.showAlert(title: "경고", message: "회원가입에 실패하셨습니다.")
                }
            })
            .disposed(by: disposeBag)
        
        AchaKeyboard.shared.keyboardHeight
            .drive(onNext: { [weak self] keyboardHeight in
                guard let self = self else {return}
                self.contentView.snp.updateConstraints {
                    $0.bottom.equalToSuperview().offset(-keyboardHeight)
                }
            })
            .disposed(by: disposeBag)

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
    
}

extension SignupViewController {
    
    private func configureStackView() {
        contentView.axis = .vertical
        contentView.spacing = 50
        contentView.backgroundColor = .white
        contentView.distribution = .fillProportionally
    }
    
    private func configureUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addArrangedSubview(titleView)
        contentView.addArrangedSubview(emailTextField)
        contentView.addArrangedSubview(passwordTextField)
        contentView.addArrangedSubview(nickNameTextField)
        contentView.addArrangedSubview(signUpButton)
        contentView.addArrangedSubview(logInButton)
        
        scrollView.snp.makeConstraints {
            $0.top.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.7)
            $0.centerX.top.bottom.equalToSuperview()
        }
        
        titleView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        emailTextField.snp.makeConstraints {
            $0.trailing.leading.equalToSuperview()
            $0.height.equalTo(60)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.height.equalTo(60)
        }
        
        nickNameTextField.snp.makeConstraints {
            $0.height.equalTo(60)
        }
        
        signUpButton.snp.makeConstraints {
            $0.height.equalTo(60)
        }
        
        logInButton.snp.makeConstraints {
            $0.height.equalTo(60)
        }
        
    }

}

extension SignupViewController {
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
