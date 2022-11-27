//
//  RecordMapViewUseCase.swift
//  Acha
//
//  Created by 배남석 on 2022/11/24.
//

import Foundation
import RxSwift

protocol RecordMapViewUseCase {
    var recordData: BehaviorSubject<[Int: RecordViewRecord]> { get set }
    var dropDownMenus: BehaviorSubject<[Map]> { get set }
    var mapNameAndRecords: BehaviorSubject<(String, [RecordViewRecord])> { get set }
    func loadMapData() -> Observable<[Map]>
    func loadRecordData() -> Observable<[RecordViewRecord]>
    func fetchRecordDataAtIndex() -> Observable<[Int: RecordViewRecord]>
    func fetchMapDataAtMapName() -> Observable<[String: Map]>
    func fetchMapDataAtCategory() -> Observable<[String: [Map]]>
    func getMapArrayAtCategory(category: String) -> Observable<[Map]>
    func getMapAtMapName(mapName: String) -> Observable<Map>
    func getDropDownMenus(mapName: String)
    func getRecordsAtIndexes(indexes: [Int]) -> Observable<[RecordViewRecord]>
    func getMapNameAndRecordsAtCategory(category: String)
    func getMapNameAndRecordsAtMapName(mapName: String)
}
