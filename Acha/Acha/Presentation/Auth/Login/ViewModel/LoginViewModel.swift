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
    
    private let useCase: LoginUseCaseProtocol
    private weak var coordinator: LoginCoordinatorProtocol?
    
    init(coordinator: LoginCoordinatorProtocol,
         useCase: LoginUseCaseProtocol) {
        self.coordinator = coordinator
        self.useCase = useCase
    }
    
    func transform(input: Input) -> Output {
        
        let bag = DisposeBag()
        
        let emailValidate = Observable<Bool>.create { observer in
            input.emailUpdated
                .subscribe { [weak self] email in
                    let result = self?.useCase.emailValidate(text: email)
                    observer.onNext(result ?? false)
                }
                .disposed(by: bag)
            return Disposables.create()
        }
        
        let passwordValidate = Observable<Bool>.create { observer in
            input.passwordUpdated
                .subscribe { [weak self] password in
                    let result = self?.useCase.passwordValidate(text: password)
                    observer.onNext(result ?? false)
                }
                .disposed(by: bag)
            return Disposables.create()
        }
        
        let loginResult = Observable<Bool>.create { observer in
            input.loginButtonDidTap
                .subscribe { [weak self] _ in
                    self?.useCase.logIn()
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
        
        input.signUpButtonDidTap
            .subscribe { [weak self] _ in
                self?.coordinator?.showSignupViewController()
            }
            .disposed(by: bag)
        
        disposeBag = bag 
        
        return Output.init(emailValidate: emailValidate,
                           passwordValidate: passwordValidate,
                           loginResult: loginResult)
    }
    
    private func translateView() {
        guard let storngCoordinator = coordinator else {return}
        storngCoordinator.delegate?.didFinished(childCoordinator: storngCoordinator)
    }
    
}
