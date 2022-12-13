//
//  DefaultRecordMapViewUseCase.swift
//  Acha
//
//  Created by 배남석 on 2022/11/22.
//

import Foundation
import RxSwift

final class DefaultRecordMapViewUseCase: RecordMapViewUseCase {
    private let recordRepository: RecordRepository
    private let mapRepository: MapRepository
    private let disposeBag = DisposeBag()
    
    var dropDownMenus = BehaviorSubject<[Map]>(value: [])
    var mapDataAtMapName = BehaviorSubject<[String: Map]>(value: [:])
    var mapDataAtCategory = BehaviorSubject<[String: [Map]]>(value: [:])
    var mapNameAndRecordDatas = BehaviorSubject<(mapName: String,
                                                 recordDatas: [Record])>(value: (mapName: "", recordDatas: []))
    
    init(recordRepository: RecordRepository, mapRepository: MapRepository) {
        self.recordRepository = recordRepository
        self.mapRepository = mapRepository
    }
    
    func loadMapData() {
        mapRepository.fetchAllMaps()
            .asObservable()
            .subscribe { maps in
                var mapDataAtCategory = [String: [Map]]()
                var mapDataAtMapName = [String: Map]()
                maps.forEach {
                    mapDataAtCategory[$0.location] = (mapDataAtCategory[$0.location] ?? []) + [$0]
                    mapDataAtMapName[$0.name] = $0
                }
                self.mapDataAtMapName.onNext(mapDataAtMapName)
                self.mapDataAtCategory.onNext(mapDataAtCategory)
            }.disposed(by: self.disposeBag)
    }
    
    func loadRecordData() -> Observable<[Record]> {
        recordRepository.fetchAllRecords()
            .asObservable()
    }
    
    func fetchRecordDatasAtMapId() -> Observable<[Int: [Record]]> {
        loadRecordData()
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
    
    func getDropDownMenus(mapName: String) {
        guard let mapDataAtMapName = try? mapDataAtMapName.value(),
              let mapData = mapDataAtMapName[mapName],
              let mapDatasAtCategory = try? mapDataAtCategory.value(),
              let mapDatas = mapDatasAtCategory[mapData.location] else { return }
        
        self.dropDownMenus.onNext(mapDatas)
    }
    
    func getMapNameAndRecordDatasAtCategory(category: String) {
        self.loadRecordData()
            .subscribe { recordDatas in
                guard let mapDatasAtCategory = try? self.mapDataAtCategory.value(),
                      let mapDatas = mapDatasAtCategory[category],
                      let recordDatas = recordDatas.element else { return }
                      let mapData = mapDatas[0]
                
                let recordDatasAtMapId = recordDatas.filter { $0.mapID == mapData.mapID && $0.isCompleted ==  true }.sorted { $0.time < $1.time }
                
                self.mapNameAndRecordDatas.onNext((mapName: mapData.name, recordDatas: recordDatasAtMapId))
            }.disposed(by: self.disposeBag)
    }
    
    func getMapNameAndRecordDatasAtMapName(mapName: String) {
        loadRecordData()
            .subscribe { recordDatas in
                guard let mapDataAtMapName = try? self.mapDataAtMapName.value(),
                      let mapData = mapDataAtMapName[mapName],
                      let recordDatas = recordDatas.element else { return }
                
                let recordDatasAtMapId = recordDatas.filter { $0.mapID == mapData.mapID && $0.isCompleted == true }.sorted { $0.time < $1.time }
                
                self.mapNameAndRecordDatas.onNext((mapName: mapData.name, recordDatas: recordDatasAtMapId))
            }.disposed(by: self.disposeBag)
    }
}
