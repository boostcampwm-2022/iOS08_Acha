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
        let logInButtonDidTap: Observable<Void>
    }
    
    struct Output {
        let passwordValidated: Observable<Bool>
        let nickNameValidated: Observable<Bool>
        let emailValidated: Observable<Bool>
        let signUpFailed: Observable<Bool>
    }
    
    private let useCase: SignUpUsecaseProtocol
    private weak var coordinator: SignupCoordinatorProtocol?
    
    init(
        coordinator: SignupCoordinatorProtocol,
        useCase: SignUpUsecaseProtocol
    ) {
        self.useCase = useCase
        self.coordinator = coordinator
    }
    
    func transform(input: Input) -> Output {
        
        let bag = DisposeBag()
        let paswordValidate =  Observable<Bool>.create { observer in
            input.passwordUpdated
                .subscribe(onNext: { [weak self] text in
                    guard let self = self else {return}
                    let result = self.useCase.passwordValidate(text: text)
                    observer.onNext(result)
                })
                .disposed(by: bag)
            return Disposables.create()
        }
        
        let emailValidate = Observable<Bool>.create { observer in
            input.emailUpdated
                .subscribe { [weak self] text in
                    guard let self = self else {return}
                    let result = self.useCase.emailValidate(text: text)
                    observer.onNext(result)
                }
                .disposed(by: bag)
            return Disposables.create()
        }
        
        let nickNameValidate = Observable<Bool>.create { observer in
            input.nickNameUpdated
                .subscribe { [weak self] text in
                    guard let self = self else {return}
                    let result = self.useCase.nickNameValidate(text: text)
                    observer.onNext(result)
                }
                .disposed(by: bag)
            return Disposables.create()
        }
        
        input.logInButtonDidTap
            .subscribe { [weak self] _ in
                self?.coordinator?.showLoginViewController()
            }
            .disposed(by: bag)
        
        let signUpButtonDidTap = Observable<Bool>.create { observer in
            input.signUpButtonDidTap
                .subscribe { [weak self] _ in
                    self?.useCase.signUp()
                        .subscribe(onNext: { _ in
                            guard let self = self else {return}
                            self.coordinator?.delegate?.didFinished(childCoordinator: self.coordinator!)
                        }, onError: { _ in
                            observer.onNext(false)
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
                      signUpFailed: signUpButtonDidTap)
    }
    
    private func transitionView() {
        guard let strongCoordinator = coordinator else {return}
        strongCoordinator.delegate?.didFinished(childCoordinator: strongCoordinator)
    }
    
}
