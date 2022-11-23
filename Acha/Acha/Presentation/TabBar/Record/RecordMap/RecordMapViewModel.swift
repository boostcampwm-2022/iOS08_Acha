//
//  RecordMapViewModel.swift
//  Acha
//
//  Created by 배남석 on 2022/11/22.
//

import Foundation
import Firebase
import RxSwift
import RxRelay

final class RecordMapViewModel: BaseViewModel {
    
    struct Input {
        var viewDidLoadEvent: Observable<Void>
    }
    
    struct Output {
        var mapDataAtCategory = PublishRelay<[String: [Map]]>()
        var mapDataAtMapName = PublishRelay<[String: Map]>()
        var recordData = PublishRelay<[Int: RecordViewRecord]>()
    }
    
    private var ref: DatabaseReference!
    let useCase: DefaultRecordMapViewUseCase!
    var disposeBag = DisposeBag()
    var recordData = [Int: RecordViewRecord]()
    var mapDataAtCategory = [String: [Map]]()
    var mapDataAtMapName = [String: Map]()
    var isFetched: Bool = false
    
    init(useCase: DefaultRecordMapViewUseCase) {
        self.ref = Database.database().reference()
        self.useCase = useCase
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.viewDidLoadEvent
            .subscribe { [weak self] _ in
                guard let self else { return }
                if !self.isFetched {
                    self.useCase.fetchAllData()
                    self.isFetched = true
                }
            }.disposed(by: disposeBag)
        
        useCase.recordData
            .bind(to: output.recordData)
            .disposed(by: disposeBag)
        
        useCase.mapDataAtMapName
            .bind(to: output.mapDataAtMapName)
            .disposed(by: disposeBag)
        
        useCase.mapDataAtCategory
            .bind(to: output.mapDataAtCategory)
            .disposed(by: disposeBag)
        
        return output
    }
}
