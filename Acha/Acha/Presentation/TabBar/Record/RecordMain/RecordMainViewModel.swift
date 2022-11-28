//
//  RecordViewModel.swift
//  Acha
//
//  Created by 배남석 on 2022/11/15.
//

import Foundation
import RxSwift
import RxRelay

class RecordMainViewModel: BaseViewModel {
    
    struct Input {
        var viewDidAppearEvent: Observable<Void>
        var headerViewBindEvent: Observable<String>
        var cellBindEvent: Observable<Int>
    }
    
    struct Output {
        var allDates = PublishRelay<[String]>()
        var weekDatas = PublishRelay<[RecordViewChartData]>()
        var headerRecord = PublishRelay<RecordViewHeaderRecord>()
        var mapAtRecordId = PublishRelay<Map>()
        var recordsAtDate = PublishRelay<[String: [Record]]>()
    }
    
    var useCase: RecordMainViewUseCase!
    var disposeBag = DisposeBag()
    
    init(useCase: DefaultRecordMainViewUseCase) {
        self.useCase = useCase
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.viewDidAppearEvent
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.useCase.getWeekDatas()
                self.useCase.getAllDates()
                self.useCase.getRecordsAtDate()
            }).disposed(by: disposeBag)
        
        input.headerViewBindEvent
            .subscribe(onNext: { [weak self] date in
                guard let self else { return }
                self.useCase.getHeaderRecord(date: date)
            }).disposed(by: disposeBag)
        
        input.cellBindEvent
            .subscribe(onNext: { [weak self] mapId in
                guard let self else { return }
                self.useCase.getRecordAtMapId(mapId: mapId)
            }).disposed(by: disposeBag)
        
        useCase.allDates
            .bind(to: output.allDates)
            .disposed(by: disposeBag)
        
        useCase.weekDatas
            .bind(to: output.weekDatas)
            .disposed(by: disposeBag)
        
        useCase.headerRecord
            .bind(to: output.headerRecord)
            .disposed(by: disposeBag)
        
        useCase.recordsAtDate
            .bind(to: output.recordsAtDate)
            .disposed(by: disposeBag)
        
        useCase.mapAtRecordId
            .bind(to: output.mapAtRecordId)
            .disposed(by: disposeBag)
        
        return output
    }
}
