//
//  LoginViewModel.swift
//  Acha
//
//  Created by hong on 2022/11/21.
//

import Foundation
import RxSwift

final class LoginViewModel: BaseViewModel {
    var disposeBag: RxSwift.DisposeBag = .init()
    
    struct Input {
        let emailUpdated: Observable<String>
        let passwordUpdated: Observable<String>
        let loginButtonDidTap: Observable<Void>
        let signUpButtonDidTap: Observable<Void>
    }

    struct Output {
        let emailValidate: Observable<Bool>
        let passwordValidate: Observable<Bool>
        let loginResult: Observable<Bool>
    }
    
    typealias LoginUseCase = EmailValidate & PasswordValidate & LoginAble
    
    private var repository: LoginReposity
    private let useCase: LoginUseCase
    private let coordinator: LoginCoordinatorProtocol & SignupCoordinatorProtocol
    
    init(coordinator: LoginCoordinatorProtocol & SignupCoordinatorProtocol,
         useCase: AuthUseCase,
         repository: AuthRepository) {
        self.coordinator = coordinator
        self.useCase = useCase
        self.repository = repository
    }
    
    func transform(input: Input) -> Output {
        
        let bag = DisposeBag()
        
        let emailValidate = Observable<Bool>.create { observer in
            input.emailUpdated
                .subscribe { [weak self] email in
                    if self?.useCase.emailValidate(text: email) ?? false {
                        self?.repository.emailValidation = true
                        self?.repository.emailRelay.accept(email)
                        observer.onNext(true)
                    } else {
                        self?.repository.emailValidation = false
                        observer.onNext(false)
                    }
                }
                .disposed(by: bag)
            return Disposables.create()
        }
        
        let passwordValidate = Observable<Bool>.create { observer in
            input.passwordUpdated
                .subscribe { [weak self] password in
                    if self?.useCase.passwordValidate(text: password) ?? false {
                        self?.repository.passwordValidation = true
                        self?.repository.passwordRelay.accept(password)
                        observer.onNext(true)
                    } else {
                        self?.repository.passwordValidation = false
                        observer.onNext(false)
                    }
                }
                .disposed(by: bag)
            return Disposables.create()
        }
        
        let loginResult = Observable<Bool>.create { observer in
            input.loginButtonDidTap
                .subscribe { [weak self] _ in
                    self?.repository.getLoginData()
                        .subscribe(onNext: { loginData in
                            if self?.repository.isLoginAble() ?? false {
                                self?.useCase.logIn(data: loginData)
                                    .subscribe(onNext: { loginResult in
                                        observer.onNext(loginResult)
                                    })
                                    .disposed(by: bag)
                            } else {
                                observer.onNext(false)
                            }
                        })
                        .disposed(by: bag)
                }
                .disposed(by: bag)
            
            return Disposables.create()
        }
        
        input.signUpButtonDidTap
            .subscribe { [weak self] _ in
                self?.coordinator.showSignupViewController()
            }
            .disposed(by: bag)
        
        return Output.init(emailValidate: emailValidate,
                           passwordValidate: passwordValidate,
                           loginResult: loginResult)
    }
    
}
