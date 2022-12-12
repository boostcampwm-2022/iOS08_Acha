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
        let viewWillAppearEvent: Observable<Void>
        let selectedCharacterIndex: Observable<IndexPath>
        let finishButtonTapped: PublishSubject<Void>
        let cancelButtonTapped: PublishSubject<Void>
    }
    // MARK: - Output
    struct Output {
        let ownedBadges = PublishSubject<[Badge]>()
    }
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private weak var delegate: CharacterSelectViewModelDelegate?
    private let ownedBadges: [Badge]
    private var selectedCharacterURL: String = ""
    
    // MARK: - Dependency
    private weak var coordinator: MyPageCoordinator?
    
    // MARK: - Lifecycles
    init(coordinator: MyPageCoordinator,
         delegate: CharacterSelectViewModelDelegate,
         ownedBadges: [Badge]) {
        self.coordinator = coordinator
        self.delegate = delegate
        self.ownedBadges = ownedBadges
    }
    
    // MARK: - Helpers
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.viewWillAppearEvent
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                output.ownedBadges.onNext(self.ownedBadges)
            }).disposed(by: disposeBag)
        
        input.selectedCharacterIndex
            .subscribe(onNext: { [weak self] indexPath in
                guard let self,
                      let badge = self.ownedBadges[safe: indexPath.row] else { return }
                self.selectedCharacterURL = badge.imageURL
            })
            .disposed(by: disposeBag)
        
        input.finishButtonTapped
            .subscribe(onNext: { [weak self] in
                guard let self,
                      let coordinator = self.coordinator,
                      let delegate = self.delegate else { return }
                delegate.deliverSelectedCharacter(imageURL: self.selectedCharacterURL)
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
