//
//  GameOverViewModel.swift
//  Acha
//
//  Created by 조승기 on 2022/11/17.
//

import Foundation
import RxSwift
import Firebase

final class GameOverViewModel: BaseViewModel {
    struct Input {
        var okButtonTapped: Observable<Void>
    }
    
    struct Output {
        var record: Record
        var mapName: String
    }
    
    private weak var coordinator: SingleGameCoordinator?
    var disposeBag = DisposeBag()
    let ref: DatabaseReference!
    var record: Record
    let map: Map
    
    private let recordID = PublishSubject<Int>()
    
    init(coordinator: SingleGameCoordinator,
         record: Record,
         map: Map,
         isCompleted: Bool
    ) {
        self.coordinator = coordinator
        self.record = record
        self.map = map
        self.ref = Database.database().reference()
        self.uploadRecord()
        if isCompleted {
            uploadMapRecord()
        }
    }
    
    func transform(input: Input) -> Output {
        input.okButtonTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.coordinator?.delegate?.didFinished(childCoordinator: self.coordinator!)
            }).disposed(by: disposeBag)
        return Output(record: record, mapName: map.name)
    }
    
    private func uploadRecord() {
        ref.child("record").observeSingleEvent(
            of: .value,
            with: { [weak self] snapshot in
                
                guard let self,
                      let snapData = snapshot.value as? [Any],
                      let data = try? JSONSerialization.data(withJSONObject: snapData),
                      var records = try? JSONDecoder().decode([Record].self, from: data)
                else {
                    print(Errors.decodeError)
                    return
                }
                
                self.record.id = records.count
                self.recordID.onNext(records.count)
                guard let json = try? JSONEncoder().encode(self.record),
                      let jsonSerial = try? JSONSerialization.jsonObject(with: json) as? [String: Any] ?? [:]
                else { return }
                
                self.ref.child("record").updateChildValues(["\(records.count)": jsonSerial])
            })
    }
    
    private func uploadMapRecord() {
        recordID.subscribe(onNext: { [weak self] recordID in
            guard let self else { return }
            self.ref.child("mapList").child("\(self.map.mapID)").observeSingleEvent(
                of: .value,
                with: { snapshot in

                    guard let snapData = snapshot.value,
                          let data = try? JSONSerialization.data(withJSONObject: snapData),
                          let mapData = try? JSONDecoder().decode(Map.self, from: data)
                    else {
                        print(Errors.decodeError)
                        return
                    }
                    
                    let newRecord = (mapData.records ?? []) + [recordID]
                    self.ref
                        .child("mapList/\(self.map.mapID)/records")
                        .setValue(newRecord)
                })
        }).disposed(by: disposeBag)
    }
}
