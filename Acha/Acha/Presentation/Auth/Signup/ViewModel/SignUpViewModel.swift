//
//  SignUpViewModel.swift
//  Acha
//
//  Created by hong on 2022/11/21.
//

import Foundation
import RxSwift
import RxCocoa

final class SignUpViewModel {
    
    var disposeBag: RxSwift.DisposeBag = .init()
    
    struct Input {
        let passwordUpdated: Observable<String>
        let nickNameUpdated: Observable<String>
        let emailUpdated: Observable<String>
        let signUpButtonDidTap: Observable<Void>
    }
    
    struct Output {
        let passwordValidated: Observable<Bool>
        let nickNameValidated: Observable<Bool>
        let emailValidated: Observable<Bool>
        let signUpSuccesssed: Observable<Bool>
    }
    
    typealias SignUpUseCase = SignUpAble & EmailValidate & PasswordValidate & NickNameValidate
    
    let useCase: SignUpUseCase
    private let coordinator: SignupCoordinatorProtocol
    var repository: SignUpRepository
    
    init(
        coordinator: SignupCoordinatorProtocol,
        useCase: SignUpUseCase,
        repository: SignUpRepository
    ) {
        self.useCase = useCase
        self.coordinator = coordinator
        self.repository = repository
    }
    
    func transform(input: Input) -> Output {
        
        let bag = DisposeBag()
        let paswordValidate =  Observable<Bool>.create { observer in
            input.passwordUpdated
                .subscribe(onNext: { [weak self] text in
                    if self?.useCase.passwordValidate(text: text) ?? false {
                        self?.repository.passwordValidation = true
                        self?.repository.passwordRelay.accept(text)
                        observer.onNext(true)
                    } else {
                        self?.repository.passwordValidation = false
                        observer.onNext(false)
                    }
                })
                .disposed(by: bag)
            return Disposables.create()
        }
        
        let emailValidate = Observable<Bool>.create { observer in
            input.emailUpdated
                .subscribe { [weak self] text in
                    if self?.useCase.emailValidate(text: text) ?? false {
                        self?.repository.emailValidation = true
                        self?.repository.emailRelay.accept(text)
                        observer.onNext(true)
                    } else {
                        self?.repository.emailValidation = false
                        observer.onNext(false)
                    }
                }
                .disposed(by: bag)
            return Disposables.create()
        }
        
        let nickNameValidate = Observable<Bool>.create { observer in
            input.nickNameUpdated
                .subscribe { [weak self] text in
                    if self?.useCase.nickNameValidate(text: text) ?? false {
                        self?.repository.nickNameValidation = true
                        self?.repository.nickNameRelay.accept(text)
                        observer.onNext(true)
                    } else {
                        self?.repository.nickNameValidation = false
                        observer.onNext(false)
                    }
                }
                .disposed(by: bag)
            return Disposables.create()
        }
        
        let signUpButtonDidTap = Observable<Bool>.create { observer in
            input.signUpButtonDidTap
                .subscribe { [weak self] _ in
                    self?.repository.getSignUpdata()
                        .subscribe(onNext: { signUpData in
                            print(signUpData)
                            if self?.repository.isSignAble() ?? false {
                                self?.useCase.signUp(data: signUpData)
                                    .subscribe(onNext: { result in
                                        observer.onNext(result)
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
        
        disposeBag = bag

        return Output(passwordValidated: paswordValidate,
                      nickNameValidated: nickNameValidate,
                      emailValidated: emailValidate,
                      signUpSuccesssed: signUpButtonDidTap)
    }
}
