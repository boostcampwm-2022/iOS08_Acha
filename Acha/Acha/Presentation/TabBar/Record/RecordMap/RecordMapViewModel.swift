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
        var sectionHeaderCreateEvent: Observable<String>
        var dropDownMenuTapEvent: Observable<String>
        var categoryCellTapEvent: Observable<String>
    }
    
    struct Output {
        var dropDownMenus = BehaviorRelay<[Map]>(value: [])
        var mapNameAndRecords = BehaviorRelay<(String, [RecordViewRecord])>(value: ("", []))
    }
    
    private var ref: DatabaseReference!
    private let useCase: RecordMapViewUseCase!
    var disposeBag = DisposeBag()
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
                self.useCase.getMapNameAndRecordsAtCategory(category: Locations.incheon.string)
            }.disposed(by: disposeBag)
        
        input.sectionHeaderCreateEvent
            .subscribe { [weak self] mapName in
                guard let self else { return }
                self.useCase.getDropDownMenus(mapName: mapName)
            }.disposed(by: disposeBag)
        
        input.dropDownMenuTapEvent
            .subscribe(onNext: { [weak self] mapName in
                guard let self else { return }
                self.useCase.getMapNameAndRecordsAtMapName(mapName: mapName)
            }).disposed(by: disposeBag)
        
        input.categoryCellTapEvent
            .subscribe(onNext: { [weak self] category in
                guard let self else { return }
                self.useCase.getMapNameAndRecordsAtCategory(category: category)
            }).disposed(by: disposeBag)
        
        useCase.dropDownMenus
            .bind(to: output.dropDownMenus)
            .disposed(by: disposeBag)
        
        useCase.mapNameAndReocrds
            .bind(to: output.mapNameAndRecords)
            .disposed(by: disposeBag)
        
        return output
    }
}
