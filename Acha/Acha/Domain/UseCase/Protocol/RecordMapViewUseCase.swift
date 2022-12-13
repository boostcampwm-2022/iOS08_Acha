//
//  RecordMapViewUseCase.swift
//  Acha
//
//  Created by 배남석 on 2022/11/24.
//

import Foundation
import RxSwift

protocol RecordMapViewUseCase {
    var dropDownMenus: BehaviorSubject<[Map]> { get set }
    var mapDataAtMapName: BehaviorSubject<[String: Map]> { get set }
    var mapDataAtCategory: BehaviorSubject<[String: [Map]]> { get set }
    var mapNameAndRecordDatas: BehaviorSubject<(mapName: String, recordDatas: [Record])> { get set }
    
    func loadMapData()
    func loadRecordData() -> Observable<[Record]>
    func getDropDownMenus(mapName: String)
    func getMapNameAndRecordsAtLocation(location: String)
    func getMapNameAndRecordDatasAtMapName(mapName: String)
}
