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
        var viewWillAppearEvent: Observable<Void>
        var regionDidChanged: PublishSubject<MapRegion>
        var startButtonTapped: Observable<Void>
        var backButtonTapped: Observable<Void>
    }
    var selectedMap: Map?
    var userLocation: Coordinate?
    
    // MARK: - Output
    struct Output {
        var visibleMap = PublishRelay<Map>()
        var cannotStart = PublishRelay<Void>()
    }
    private var maps: [Map]
    private var visbleMapsIdx: [Int]
    var rankings: [Int: [Record]]
    
    // MARK: - Properties
    private var ref: DatabaseReference!
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.viewWillAppearEvent
            .subscribe(onNext: { [weak self] _ in
                self?.fetchAllMaps()
            })
            .disposed(by: disposeBag)
        
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
        
        input.regionDidChanged
            .subscribe(onNext: { [weak self] region in
                guard let self else { return }
                let northWestCorner = Coordinate(latitude: region.center.latitude-(region.span.latitudeDelta / 2.0),
                                                 longitude: region.center.longitude-(region.span.longitudeDelta / 2.0))
                let southEastCorner = Coordinate(latitude: region.center.latitude+(region.span.latitudeDelta / 2.0),
                                                 longitude: region.center.longitude+(region.span.longitudeDelta / 2.0))

                self.maps.filter { !self.visbleMapsIdx.contains($0.mapID)}
                    .forEach { map in
                        let first = map.coordinates.first { coordinate in
                            coordinate.latitude >= northWestCorner.latitude &&
                            coordinate.latitude <= southEastCorner.latitude &&
                            coordinate.longitude >= northWestCorner.longitude &&
                            coordinate.longitude <= southEastCorner.longitude
                        }
                        if first != nil {
                            output.visibleMap.accept(map)
                            self.visbleMapsIdx.append(map.mapID)
                        }
                    }
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
        self.maps = []
        self.rankings = [:]
        self.visbleMapsIdx = []
    }
    
    // MARK: - Helpers
    func fetchAllMaps() {
        self.ref.child("mapList").observeSingleEvent(of: .value,
                                                with: { snapshot in
            guard let snapData = snapshot.value as? [Any],
                  let data = try? JSONSerialization.data(withJSONObject: snapData),
                  let mapDatas = try? JSONDecoder().decode([Map].self, from: data)
            else {
                print(Errors.decodeError, " Map")
                return
            }
            
            self.maps = mapDatas
            mapDatas.forEach { map in
                self.fetchMapRecord(mapID: map.mapID)
                    .subscribe {
                        self.rankings[map.mapID] = $0
                    }.disposed(by: self.disposeBag)
            }
        })
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
