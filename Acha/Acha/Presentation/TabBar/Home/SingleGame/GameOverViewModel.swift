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
        var viewDidLoad: Observable<Void>
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
    
    init(coordinator: SingleGameCoordinator,
         record: Record,
         map: Map
    ) {
        self.coordinator = coordinator
        self.record = record
        self.map = map
        self.ref = Database.database().reference()
    }
    
    func transform(input: Input) -> Output {
        input.okButtonTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.coordinator?.delegate?.didFinished(childCoordinator: self.coordinator!)
            }).disposed(by: disposeBag)
        input.viewDidLoad
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.uploadRecord()
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
                      let records = try? JSONDecoder().decode([Record].self, from: data)
                else {
                    print(Errors.decodeError, #function)
                    return
                }
                
                self.record.id = records.count

                guard let json = try? JSONEncoder().encode(self.record),
                      let jsonSerial = try? JSONSerialization.jsonObject(with: json) as? [String: Any] ?? [:]
                else { return }
                
                self.ref.child("record").updateChildValues(["\(records.count)": jsonSerial])
            })
    }
}
