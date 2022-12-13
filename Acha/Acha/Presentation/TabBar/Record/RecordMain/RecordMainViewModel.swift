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
    }
    
    struct Output {
        var weekDatas = PublishRelay<[RecordViewChartData]>()
        var recordSectionDatas = PublishRelay<(allDates: [String],
                                               totalRecordAtDate: [String: DayTotalRecord],
                                               recordsAtDate: [String: [Record]],
                                               mapNameAtMapId: [Int: String])>()
    }
    
    var useCase: RecordMainViewUseCase
    var disposeBag = DisposeBag()
    
    init(useCase: RecordMainViewUseCase) {
        self.useCase = useCase
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.viewDidAppearEvent
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.useCase.loadMapData()
                self.useCase.loadRecordData()
            }).disposed(by: disposeBag)
        
        useCase.weekDatas
            .bind(to: output.weekDatas)
            .disposed(by: disposeBag)
        
        useCase.recordSectionDatas
            .bind(to: output.recordSectionDatas)
            .disposed(by: disposeBag)
        
        return output
    }
}
