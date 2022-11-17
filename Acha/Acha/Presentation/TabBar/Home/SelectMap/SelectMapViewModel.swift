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
    }
    var mapTapped = PublishRelay<Map>()
    var selectedMap: Map?
    
    // MARK: - Output
    struct Output {
        var mapCoordinates: Single<[Map]>
//        var mapTop3Ranking: Single<[AchaRecord]>
    }
    var maps: [Int: Map]
    var rankings: [Int: [AchaRecord]]
    
    // MARK: - Properties
    var ref: DatabaseReference!
    
    func transform(input: Input) -> Output {
        
        input.startButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self,
                      let map = self.selectedMap else { return }
                self.coordinator.showSingleGamePlayViewController(selectedMap: map)
            })
            .disposed(by: disposeBag)
        
//        var top3Rankings = Single<[AchaRecord]>
//        mapTapped.subscribe(onNext: { [weak self] map in
//            top3Rankings = Single.create { single in
//                if let rankings = self?.rankings[map.mapID] {
//                    single(.success(rankings))
//                }
//                return Disposables.create()
//            }
//        }).disposed(by: disposeBag)
//
        return Output(mapCoordinates: fetchAllMaps())
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
            self?.ref.child("mapList").observeSingleEvent(of: .value,
                                                    with: { snapshot in
                guard let snapData = snapshot.value as? [Any],
                      let data = try? JSONSerialization.data(withJSONObject: snapData),
                      let mapDatas = try? JSONDecoder().decode([Map].self, from: data)
                else {
                    print(Errors.decodeError)
                    return
                }
                
                mapDatas.forEach { map in
                    self?.fetchMapRecord(mapID: map.mapID)
                        .subscribe {
                            self?.rankings[map.mapID] = $0
                        }.disposed(by: self!.disposeBag)
                }
                
                single(.success(mapDatas))
            })
            return Disposables.create()
        }
    }
    
    func fetchMapRecord(mapID: Int) -> Single<[AchaRecord]> {
        return Single.create { [weak self] single in
            self?.ref.child("record").observeSingleEvent(of: .value,
                                                   with: { snapshot in
                guard let snapData = snapshot.value as? [Any],
                      let data = try? JSONSerialization.data(withJSONObject: snapData),
                      let records = try? JSONDecoder().decode([AchaRecord].self, from: data)
                else { return }
                
                let rankings = Array(records.filter { $0.mapID == mapID }.sorted { $0.time < $1.time }.prefix(3))
                return single(.success(rankings))
            })
            return Disposables.create()
        }
    }
}
