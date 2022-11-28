//
//  RecordViewUseCase.swift
//  Acha
//
//  Created by 배남석 on 2022/11/21.
//

import Foundation
import RxSwift

protocol RecordMainViewUseCase {
    var recordDatas: BehaviorSubject<[Record]> { get set }
    var mapDatas: BehaviorSubject<[Map]> { get set }
    var allDates: PublishSubject<[String]> { get set }
    var weekDatas: PublishSubject<[RecordViewChartData]> { get set }
    var headerRecord: PublishSubject<RecordViewHeaderRecord> { get set }
    var mapAtRecordId: PublishSubject<Map> { get set }
    var recordsAtDate: PublishSubject<[String: [Record]]> { get set }
    
    func loadMapData()
    func loadRecordData()
    func fetchTotalDataAtDay() -> Observable<[String: DayTotalRecord]>
    func getRecordsAtDate()
    func getAllDates()
    func getWeekDatas()
    func getHeaderRecord(date: String)
    func getRecordAtMapId(mapId: Int)
}
