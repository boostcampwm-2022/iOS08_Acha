//
//  RecordMapViewModel.swift
//  Acha
//
//  Created by 배남석 on 2022/11/22.
//

import Foundation
import RxSwift
import RxRelay

final class RecordMapViewModel: BaseViewModel {
    
    struct Input {
        var viewDidAppearEvent: Observable<Void>
        var sectionHeaderCreateEvent: Observable<String>
        var dropDownMenuTapEvent: Observable<String>
        var categoryCellTapEvent: Observable<String>
    }
    
    struct Output {
        var dropDownMenus = BehaviorRelay<[Map]>(value: [])
        var mapNameAndRecordDatas = BehaviorRelay<(mapName: String, recordDatas: [Record])>(value: ("", []))
    }
    
    private let useCase: RecordMapViewUseCase
    var disposeBag = DisposeBag()
    
    init(useCase: RecordMapViewUseCase) {
        self.useCase = useCase
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.viewDidAppearEvent
            .subscribe { [weak self] _ in
                guard let self else { return }
                self.useCase.loadMapData()
                self.useCase.getMapNameAndRecordDatasAtCategory(category: Locations.incheon.string)
            }.disposed(by: disposeBag)
        
        input.sectionHeaderCreateEvent
            .subscribe { [weak self] mapName in
                guard let self else { return }
                self.useCase.getDropDownMenus(mapName: mapName)
            }.disposed(by: disposeBag)
        
        input.dropDownMenuTapEvent
            .subscribe(onNext: { [weak self] mapName in
                guard let self else { return }
                self.useCase.getMapNameAndRecordDatasAtMapName(mapName: mapName)
            }).disposed(by: disposeBag)
        
        input.categoryCellTapEvent
            .subscribe(onNext: { [weak self] category in
                guard let self else { return }
                self.useCase.getMapNameAndRecordDatasAtCategory(category: category)
            }).disposed(by: disposeBag)
        
        useCase.dropDownMenus
            .bind(to: output.dropDownMenus)
            .disposed(by: disposeBag)
        
        useCase.mapNameAndRecordDatas
            .bind(to: output.mapNameAndRecordDatas)
            .disposed(by: disposeBag)
        
        return output
    }
}
