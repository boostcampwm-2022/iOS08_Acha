//
//  CharacterSelectViewModel.swift
//  Acha
//
//  Created by  sangyeon on 2022/12/11.
//

import Foundation
import RxSwift

protocol CharacterSelectViewModelDelegate: AnyObject {
    func deliverSelectedCharacter(imageURL: String)
}

final class CharacterSelectViewModel: BaseViewModel {

    // MARK: - Input
    struct Input {
        let selectedCharacterIndex: Observable<IndexPath>
        let finishButtonTapped: PublishSubject<Void>
        let cancelButtonTapped: PublishSubject<Void>
    }
    // MARK: - Output
    struct Output {}
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private weak var delegate: CharacterSelectViewModelDelegate?
    private var selectedCharacterImageURL: String = "firstAnnotation"
    
    // MARK: - Dependency
    private weak var coordinator: MyPageCoordinator?
    
    // MARK: - Lifecycles
    init(coordinator: MyPageCoordinator,
         delegate: CharacterSelectViewModelDelegate) {
        self.coordinator = coordinator
        self.delegate = delegate
    }
    
    // MARK: - Helpers
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.selectedCharacterIndex
            .subscribe(onNext: { [weak self] indexPath in
                guard let self,
                      let character = PinCharacter.allCases[safe: indexPath.row] else { return }
                self.selectedCharacterImageURL = character.rawValue
            })
            .disposed(by: disposeBag)
        
        input.finishButtonTapped
            .subscribe(onNext: { [weak self] in
                guard let self,
                      let coordinator = self.coordinator,
                      let delegate = self.delegate else { return }
                delegate.deliverSelectedCharacter(imageURL: self.selectedCharacterImageURL)
                coordinator.didFinished(childCoordinator: coordinator)
            })
            .disposed(by: disposeBag)
        
        input.cancelButtonTapped
            .subscribe(onNext: { [weak self] in
                guard let self,
                      let coordinator = self.coordinator else { return }
                coordinator.didFinished(childCoordinator: coordinator)
            })
            .disposed(by: disposeBag)

        return output
    }
}
