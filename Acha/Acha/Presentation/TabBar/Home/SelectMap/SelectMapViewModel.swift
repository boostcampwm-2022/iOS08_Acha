//
//  SelectMapViewModel.swift
//  Acha
//
//  Created by 조승기 on 2022/11/14.
//

import Foundation
import Firebase
import RxSwift
import RxRelay

class SelectMapViewModel: BaseViewModel {
    
    struct Input {
        var startButtonTapped: Observable<Void>
    }
    struct Output {
        
    }
    
    func transform(input: Input) -> Output {
        input.startButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self,
                      let map = self.selectedMap else { return }
                self.coordinator.showSingleGamePlayViewController(selectedMap: map)
            })
            .disposed(by: disposeBag)
        return Output()
    }
    
    var selectedMap: Map?
    var disposeBag = DisposeBag()
    var ref: DatabaseReference!
    var coordinator: SingleGameCoordinator
    var mapCoordinates = PublishRelay<[Map]>()
    
    init(coordinator: SingleGameCoordinator) {
        self.ref = Database.database().reference()
        self.coordinator = coordinator
    }
    
    func fetchAllMaps() {
        ref.child("mapList").observeSingleEvent(of: .value,
                                                with: { [weak self] snapshot in
            guard let snapData = snapshot.value as? [Any],
                  let data = try? JSONSerialization.data(withJSONObject: snapData),
                  let maps = try? JSONDecoder().decode([Map].self, from: data)
            else {
                print(Errors.decodeError, " Map")
                return
            }
            self?.mapCoordinates.accept(maps)
        })
    }
}
