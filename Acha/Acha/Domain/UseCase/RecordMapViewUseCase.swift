//
//  RecordMapViewUseCase.swift
//  Acha
//
//  Created by 배남석 on 2022/11/24.
//

import Foundation
import RxSwift

protocol RecordMapViewUseCase {
    var mapDatas: BehaviorSubject<[Map]> { get set }
    var dropDownMenus: BehaviorSubject<[Map]> { get set }
    var mapDataAtMapName: BehaviorSubject<[String: Map]> { get set }
    var mapDataAtCategory: BehaviorSubject<[String: [Map]]> { get set }
    
    func loadMapData()
    func loadRecordData() -> Observable<[Record]>
    func fetchRecordDatasAtMapId() -> Observable<[Int: [Record]]>
    func fetchMapDataAtMapName()
    func fetchMapDatasAtCategory()
    func getDropDownMenus(mapName: String)
    func getRecordDatasAtMapId(mapId: Int) -> Observable<[Record]>
    func getMapNameAndRecordDatasAtCategory(category: String) -> Observable<(mapName: String, recordDatas: [Record])>
    func getMapNameAndRecordDatasAtMapName(mapName: String) -> Observable<(mapName: String, recordDatas: [Record])>
}
