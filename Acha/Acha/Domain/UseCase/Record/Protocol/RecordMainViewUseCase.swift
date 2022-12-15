//
//  RecordViewUseCase.swift
//  Acha
//
//  Created by 배남석 on 2022/11/21.
//

import Foundation
import RxSwift
// swiftlint:disable: large_tuple
protocol RecordMainViewUseCase {
    var mapAtMapId: BehaviorSubject<[Int: Map]> { get set }
    var weekDatas: PublishSubject<[RecordViewChartData]> { get set }
    var recordSectionDatas: PublishSubject<(allDates: [String],
                                            totalRecordAtDate: [String: DayTotalRecord],
                                            recordsAtDate: [String: [Record]],
                                            mapAtMapId: [Int: Map])> { get set }
    
    func loadMapData() -> Single<Void>
    func loadRecordData()
}
