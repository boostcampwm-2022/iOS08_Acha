//
//  SelectMapViewModel.swift
//  Acha
//
//  Created by 조승기 on 2022/11/14.
//

import Foundation
import Firebase
import RxSwift
import RxCocoa

class SelectMapViewModel: BaseViewModel {
    
    struct Input {
        var startButtonTapped: Observable<Void>
    }
    struct Output {
        var mapCoordinates: Single<[Map]>
    }
    
    func transform(input: Input) -> Output {
        input.startButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self,
                      let map = self.selectedMap else { return }
                self.coordinator.showSingleGamePlayViewController(selectedMap: map)
            })
            .disposed(by: disposeBag)
        
        return Output(mapCoordinates: fetchAllMaps())
    }
    
    var selectedMap: Map?
    var disposeBag = DisposeBag()
    var ref: DatabaseReference!
    var coordinator: SingleGameCoordinator
    
    init(coordinator: SingleGameCoordinator) {
        self.ref = Database.database().reference()
        self.coordinator = coordinator
    }
    
    func fetchAllMaps() -> Single<[Map]> {
        return Single.create { [weak self] single in
            self?.ref.child("mapList").observeSingleEvent(of: .value,
                                                    with: { snapshot in
                guard let snapData = snapshot.value as? [Any],
                      let data = try? JSONSerialization.data(withJSONObject: snapData),
                      let maps = try? JSONDecoder().decode([Map].self, from: data)
                else {
                    print(Errors.decodeError)
                    return
                }
                single(.success(maps))
            })
            return Disposables.create()
        }
    }
}
