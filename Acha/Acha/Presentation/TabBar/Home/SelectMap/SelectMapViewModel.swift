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
    
    // MARK: - Input
    struct Input {
        var startButtonTapped: Observable<Void>
        var backButtonTapped: Observable<Void>
    }
    var mapTapped = PublishRelay<Map>()
    var selectedMap: Map?
    var userLocation: Coordinate?
    
    // MARK: - Output
    struct Output {
        var mapCoordinates: Single<[Map]>
        var cannotStart = PublishRelay<Void>()
    }
    private var maps: [Int: Map]
    var rankings: [Int: [Record]]
    
    // MARK: - Properties
    private var ref: DatabaseReference!
    
    func transform(input: Input) -> Output {
        
        let output = Output(mapCoordinates: fetchAllMaps())
        
        input.startButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self,
                      let map = self.selectedMap,
                      let userLocation = self.userLocation else { return }
                guard let minDistance = map.coordinates.map({ userLocation.distance(from: $0) }).min() else { return }
                if minDistance > 5 {
                    output.cannotStart.accept(())
                }
                self.coordinator.showSingleGamePlayViewController(selectedMap: map)
            })
            .disposed(by: disposeBag)
        
        input.backButtonTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.coordinator.delegate?.didFinished(childCoordinator: self.coordinator)
            })
            .disposed(by: disposeBag)
    
        return output
    }
    
    // MARK: - Dependency
    var disposeBag = DisposeBag()
    var coordinator: SingleGameCoordinator
    
    // MARK: - Lifecycles
    init(coordinator: SingleGameCoordinator) {
        self.ref = Database.database().reference()
        self.coordinator = coordinator
        self.maps = [:]
        self.rankings = [:]
    }
    
    // MARK: - Helpers
    func fetchAllMaps() -> Single<[Map]> {
        return Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            self.ref.child("mapList").observeSingleEvent(of: .value,
                                                    with: { snapshot in
                guard let snapData = snapshot.value as? [Any],
                      let data = try? JSONSerialization.data(withJSONObject: snapData),
                      let mapDatas = try? JSONDecoder().decode([Map].self, from: data)
                else {
                    print(Errors.decodeError)
                    return
                }
                
                mapDatas.forEach { map in
                    self.fetchMapRecord(mapID: map.mapID)
                        .subscribe {
                            self.rankings[map.mapID] = $0
                        }.disposed(by: self.disposeBag)
                }
                
                single(.success(mapDatas))
            })
            return Disposables.create()
        }
    }
    
    func fetchMapRecord(mapID: Int) -> Single<[Record]> {
        return Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            self.ref.child("record").observeSingleEvent(of: .value,
                                                   with: { snapshot in
                guard let snapData = snapshot.value as? [Any],
                      let data = try? JSONSerialization.data(withJSONObject: snapData),
                      let records = try? JSONDecoder().decode([Record].self, from: data)
                else { return }
                
                let rankings = Array(records.filter { $0.mapID == mapID }.sorted { $0.time < $1.time }.prefix(3))
                return single(.success(rankings))
            })
            return Disposables.create()
        }
    }
}
