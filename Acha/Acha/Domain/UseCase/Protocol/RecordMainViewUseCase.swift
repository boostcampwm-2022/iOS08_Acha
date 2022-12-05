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
    var mapNameAtMapId: BehaviorSubject<[Int: String]> { get set }
    var weekDatas: PublishSubject<[RecordViewChartData]> { get set }
    var recordSectionDatas: PublishSubject<(allDates: [String],
                                            totalRecordAtDate: [String: DayTotalRecord],
                                            recordsAtDate: [String: [Record]],
                                            mapNameAtMapId: [Int: String])> { get set }
    
    func loadMapData()
    func loadRecordData()
}
