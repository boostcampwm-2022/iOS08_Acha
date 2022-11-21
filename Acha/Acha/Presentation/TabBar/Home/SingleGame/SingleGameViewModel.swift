//
//  SingleGameViewModel.swift
//  Acha
//
//  Created by 조승기 on 2022/11/15.
//

import Foundation
import RxRelay
import RxSwift

struct AchaRecord: Hashable, Decodable {
    var mapID: Int
    var userID: String
    var calorie: Int
    var distance: Int
    var time: Int
    var isSingleMode: Bool
    var isWin: Bool?
    var createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case mapID = "map_id"
        case userID = "user_id"
        case calorie
        case distance
        case time
        case isSingleMode
        case isWin
        case createdAt = "created_at"
    }
}

final class SingleGameViewModel {
    
    // MARK: - Input
    var currentCoordinate = PublishRelay<Coordinate>()
    struct Input {
        var gameOverButtonTapped: Observable<Void>
    }
    
    // MARK: - Output
    var route = [Coordinate]()
    struct Output {
        
    }
    
    // 사용자가 이동한 두 점의 좌표 (과거좌표, 현재좌표)
    let userMovedCoordinates = BehaviorRelay<(previous: Coordinate?, current: Coordinate?)>(value: (nil, nil))
    // 방문한 땅의 좌표 (회색 중에서, 이전 방문과 현재 방문 좌표 )
    let visitedMapCoordinates = BehaviorRelay<(previous: Coordinate?, current: Coordinate?)>(value: (nil, nil))
    let time = BehaviorRelay<Int>(value: 0)
    let movedDistance = BehaviorRelay<Double>(value: 0.0)
    let isHideGameOverButton = BehaviorRelay<Bool>(value: true)
    let tooFarFromMapEvent = PublishRelay<Void>()
    
    // MARK: - Dependency
    private let coordinator: SingleGameCoordinator
    let map: Map
    private let disposeBag = DisposeBag()
    private var hideButtonTimer: DispatchSourceTimer?
    
    // MARK: - Lifecycle
    init(coordinator: SingleGameCoordinator, map: Map) {
        self.map = map
        self.coordinator = coordinator
        bind()
        configureTimer()
    }
    
    // MARK: - Helpers
    func transform(input: Input) -> Output {
        input.gameOverButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                let kcal = Int(0.1128333333*Double(self.time.value))
                let record = AchaRecord(mapID: self.map.mapID,
                                        userID: "배변조홍",
                                        calorie: kcal,
                                        distance: Int(self.movedDistance.value),
                                        time: self.time.value,
                                        isSingleMode: true,
                                        createdAt: Date().convertToStringFormat(format: "yyyy-MM-dd"))
                self.coordinator
                    .showSingleGameOverViewController(record: record, mapName: self.map.name)
            }).disposed(by: disposeBag)
        return Output()
    }
    private func bind() {
        currentCoordinate
            .subscribe(onNext: { [weak self] coordinate in
                guard let self else { return }
                self.userMoved(coordinate: coordinate)
            }).disposed(by: disposeBag)
        
        isHideGameOverButton
            .subscribe(onNext: { [weak self] isHide in
                guard let self else { return }
                if !isHide {
                    self.isHideTimerStart()
                }
            }).disposed(by: disposeBag)
    }
    
    func userMoved(coordinate current: Coordinate) {
        route.append(current)
        
        // 첫 위치 등록의 경우 건너뜀, 빨간선 잇기 위해
        guard let userMovedPrevious = userMovedCoordinates.value.current else {
            userMovedCoordinates.accept((nil, current))
            return
        }
        userMovedCoordinates.accept((userMovedCoordinates.value.current, current))
        
        // Distance 기록
        let newDistance = movedDistance.value + meterDistance(
            from: userMovedPrevious,
            here: current
        )
        if !newDistance.isNaN {
            movedDistance.accept(newDistance)
        }
        
        // 게임) 가장 가까운 등록된 좌표 ( 현재위치와 회색 라인으로 보이는 점중 가장 가까운 점 )
        guard let nearestMapCoordinate = map.coordinates.min(by: {
            self.meterDistance(from: $0, here: current) < self.meterDistance(from: $1, here: current)
        }) else { return }
        
        // 그 사이의 거리
        let nearestDistance = meterDistance(from: nearestMapCoordinate, here: current)
        
        // 거리가 바운더리 내인 경우
        if nearestDistance < 5 {
            // if -> 처음 땅을 밟음
            if visitedMapCoordinates.value.current == nil {
                visitedMapCoordinates.accept((nil, nearestMapCoordinate))
            } else { // (과거의 과거, 과거) -> (과거, 현재)
                visitedMapCoordinates.accept((visitedMapCoordinates.value.current, nearestMapCoordinate))
            }
        }
        
        if nearestDistance > 10 {
            tooFarFromMapEvent.accept(())
        }

    }
    
    private func meterDistance(from: Coordinate, here: Coordinate) -> Double {
        let theta = from.longitude - here.longitude
        let dist = sin(from.latitude.degreeToRadian()) *
        sin(here.latitude.degreeToRadian()) +
        cos(from.latitude.degreeToRadian()) *
        cos(here.latitude.degreeToRadian()) *
        cos(theta.degreeToRadian())
    
        return acos(dist).radianToDegree() * 60 * 1.853159616 * 1000
    }
    
    private func configureTimer() {
        startTimer()
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            self.time.accept(self.time.value + 1)
        })
    }
    
    private func isHideTimerStart() {
        hideButtonTimer?.cancel()
        hideButtonTimer = nil
        hideButtonTimer = DispatchSource.makeTimerSource()
        hideButtonTimer?.schedule(deadline: .now() + 3)
        hideButtonTimer?.setEventHandler(handler: {
            self.isHideGameOverButton.accept(true)
        })
        hideButtonTimer?.resume()
    }
}
