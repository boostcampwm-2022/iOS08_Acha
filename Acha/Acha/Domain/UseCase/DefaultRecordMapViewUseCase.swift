//
//  DefaultRecordMapViewUseCase.swift
//  Acha
//
//  Created by 배남석 on 2022/11/22.
//

import Foundation
import RxSwift

final class DefaultRecordMapViewUseCase: RecordMapViewUseCase {
    private let repository: RecordRepository
    private let disposeBag = DisposeBag()
    
    var mapDatas = BehaviorSubject<[Map]>(value: [])
    var dropDownMenus = BehaviorSubject<[Map]>(value: [])
    var mapDataAtMapName = BehaviorSubject<[String: Map]>(value: [:])
    var mapDataAtCategory = BehaviorSubject<[String: [Map]]>(value: [:])
    
    init(repository: RecordRepository) {
        self.repository = repository
    }
    
    func loadMapData() {
        self.repository.fetchMapData()
            .subscribe { maps in
                self.mapDatas.onNext(maps)
            }.disposed(by: self.disposeBag)
    }
    
    func loadRecordData() -> Observable<[Record]> {
        return Observable.create { emitter in
            self.repository.fetchRecordData()
                .subscribe(onNext: { records in
                    emitter.onNext(records)
                }).disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func fetchRecordDatasAtMapId() -> Observable<[Int: [Record]]> {
        self.loadRecordData()
            .flatMap { records -> Observable<[Int: [Record]]> in
                var recordDatasAtMapId = [Int: [Record]]()
                records.forEach {
                    recordDatasAtMapId[$0.mapID] = (recordDatasAtMapId[$0.mapID] ?? []) + [$0]
                }
                return Observable.create { emitter in
                    emitter.onNext(recordDatasAtMapId)
                    
                    return Disposables.create()
                }
            }
    }
     
    func fetchMapDataAtMapName() {
        guard let maps = try? mapDatas.value() else { return }
        var mapDataAtMapName = [String: Map]()
        maps.forEach {
            mapDataAtMapName[$0.name] = $0
        }
        self.mapDataAtMapName.onNext(mapDataAtMapName)
    }
    
    func fetchMapDatasAtCategory() {
        guard let maps = try? mapDatas.value() else { return }
        var mapDataAtCategory = [String: [Map]]()
        maps.forEach {
            mapDataAtCategory[$0.location] = (mapDataAtCategory[$0.location] ?? []) + [$0]
        }
        self.mapDataAtCategory.onNext(mapDataAtCategory)
    }
    
    func getDropDownMenus(mapName: String) {
        guard let mapDataAtMapName = try? mapDataAtMapName.value(),
              let mapData = mapDataAtMapName[mapName],
              let mapDatasAtCategory = try? mapDataAtCategory.value(),
              let mapDatas = mapDatasAtCategory[mapData.location] else { return }
        
        self.dropDownMenus.onNext(mapDatas)
    }
    
    func getRecordDatasAtMapId(mapId: Int) -> Observable<[Record]> {
        return fetchRecordDatasAtMapId()
            .map { recordDatasAtMapId in
                guard let records = recordDatasAtMapId[mapId] else { return [] }
                return records.sorted { $0.time < $1.time }
            }
    }
    
    func getMapNameAndRecordDatasAtCategory(category: String) -> Observable<(mapName: String, recordDatas: [Record])> {
        return Observable.create { emitter in
            self.loadRecordData()
                .subscribe { recordDatas in
                    guard let mapDatasAtCategory = try? self.mapDataAtCategory.value(),
                          let mapDatas = mapDatasAtCategory[category],
                          let recordDatas = recordDatas.element else { return }
                          let mapData = mapDatas[0]
                    
                    let recordDatasAtMapId = recordDatas.filter { $0.mapID == mapData.mapID && $0.isCompleted ==  true }
                    
                    emitter.onNext((mapName: mapData.name, recordDatas: recordDatasAtMapId))
                }.disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    func getMapNameAndRecordDatasAtMapName(mapName: String) -> Observable<(mapName: String, recordDatas: [Record])> {
        return Observable.create { emitter in
            self.loadRecordData()
                .subscribe { recordDatas in
                    guard let mapDataAtMapName = try? self.mapDataAtMapName.value(),
                          let mapData = mapDataAtMapName[mapName],
                          let recordDatas = recordDatas.element else { return }
                    
                    let recordDatasAtMapId = recordDatas.filter { $0.mapID == mapData.mapID && $0.isCompleted == true }
                    
                    emitter.onNext((mapName: mapData.name, recordDatas: recordDatasAtMapId))
                }.disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
}
