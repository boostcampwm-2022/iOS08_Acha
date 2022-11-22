//
//  RecordViewModel.swift
//  Acha
//
//  Created by 배남석 on 2022/11/15.
//

import Foundation
import UIKit
import RxSwift
import RxRelay
import Firebase

class RecordMainViewModel: BaseViewModel {
    
    struct Input {
        var viewDidLoadEvent: Observable<Void>
    }
    
    struct Output {
        var isFinishedFetch = PublishRelay<Bool>()
        var days = PublishRelay<[String]>()
        var recordAtDays = PublishRelay<[String: [RecordViewRecord]]>()
        var weekDistances = PublishRelay<[RecordViewChartData]>()
        var sectionDays = PublishRelay<[String: DayTotalRecord]>()
        var mapData = PublishRelay<[Int: Map]>()
    }
    
    private var ref: DatabaseReference!
    var useCase: DefaultRecordViewUseCase!
    var disposeBag = DisposeBag()
    
    var sectionDays = [String: DayTotalRecord]()
    var mapData = [Int: Map]()
    var isFethed: Bool = false
    
    init(useCase: DefaultRecordViewUseCase) {
        self.ref = Database.database().reference()
        self.useCase = useCase
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.viewDidLoadEvent
            .subscribe { [weak self] _ in
                guard let self else { return }
                if !self.isFethed {
                    self.useCase.fetchAllData()
                    self.isFethed = true
                }
            }.disposed(by: disposeBag)
        
        useCase.days
            .bind(to: output.days)
            .disposed(by: disposeBag)
        
        useCase.sectionDays
            .bind(to: output.sectionDays)
            .disposed(by: disposeBag)
        
        useCase.weekDistances
            .bind(to: output.weekDistances)
            .disposed(by: disposeBag)
        
        useCase.recordAtDays
            .bind(to: output.recordAtDays)
            .disposed(by: disposeBag)
        useCase.mapData
            .bind(to: output.mapData)
            .disposed(by: disposeBag)
        
        return output
    }
    
    func searchMapName(mapId: Int) -> String {
        guard let mapData = self.mapData[mapId] else { return "" }
        let mapName = mapData.name
        return mapName
    }
}
