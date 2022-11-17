//
//  SingleGamePlayViewController.swift
//  Acha
//
//  Created by hong on 2022/11/15.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa

final class SingleGamePlayViewController: UIViewController, DistanceAndTimeBarLine {
    // MARK: - UI properties
    private let mapView = MKMapView()
    private let resetButton: UIButton = {
        let button = UIButton()
        button.setImage(
            ImageConstants
                .arrowPositionResetImage?
                .withTintColor(
                    .pointLight ?? UIColor(),
                    renderingMode: .alwaysOriginal
                ),
            for: .normal
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var distanceAndTimeBar = DistanceAndTimeBar()
    private let rightMenuButton: UIButton = {
        let button = UIButton()
        button.setImage(
            ImageConstants.inGameMenuButtonImage?
                .withTintColor(
                    .pointLight ?? UIColor(),
                    renderingMode: .alwaysOriginal
                ),
            for: .normal
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    #warning("더미 데이터임 삭제 요망")
    private let firstLoction = CLLocation(latitude: 37.517496, longitude: 126.959118)
    private let viewModel: SingleGamePlayViewModel
    // MARK: - Lifecycles
    
    init(viewModel: SingleGamePlayViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        mapViewSetting()
        bind()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureDistanceAndTimeBarBottomUI()
    }
    
    private func configureDistanceAndTimeBarBottomUI() {
        distanceAndTimeBarBottomLineAdjust(color: .white, width: 3)
        distanceAndTimeBarMiddleLineAdjust(color: .white, width: 3)
    }
}

// MARK: - Helpers
extension SingleGamePlayViewController {
    private func layout() {
        addViews()
        layoutViews()
        rightMenuButtonSetting()
    }
    
    private func addViews() {
        view.addSubview(mapView)
        view.addSubview(resetButton)
        view.addSubview(distanceAndTimeBar)
        view.addSubview(rightMenuButton)
    }
    
    private func layoutViews() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        
            rightMenuButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            rightMenuButton.heightAnchor.constraint(equalToConstant: 50),
            rightMenuButton.widthAnchor.constraint(equalToConstant: 50),
            rightMenuButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            
            distanceAndTimeBar.widthAnchor.constraint(equalTo: view.widthAnchor),
            distanceAndTimeBar.heightAnchor.constraint(equalToConstant: 100),
            distanceAndTimeBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            resetButton.bottomAnchor.constraint(equalTo: distanceAndTimeBar.topAnchor, constant: -10),
            resetButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            resetButton.widthAnchor.constraint(equalToConstant: 50),
            resetButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func mapViewSetting() {
        mapView.centerToLocation(firstLoction)
    }
    
    private func rightMenuButtonSetting() {
        #warning("더미 데이터 입니다")
        let menuItems: [UIAction] =
        [
            UIAction(title: "랭킹", handler: { [weak self] _ in
                let viewController = InGameRankingViewController()
                viewController.fetchData(data: [.init(time: 90, userName: "해피", date: Date()),
                                                .init(time: 120, userName: "멍멍이", date: Date()),
                                                .init(time: 190, userName: "웅이", date: Date())])
                self?.presentModal(viewController: viewController)
            }),
            UIAction(title: "기록", handler: { [weak self] _ in
                let viewController = InGameRecordViewController()
                viewController.fetchData(data: [.init(time: 90, userName: "해피", date: Date()),
                                                .init(time: 66, userName: "해피", date: Date())])

                self?.presentModal(viewController: viewController)
            })
        ]
        let menu = UIMenu(title: "", children: menuItems)
        rightMenuButton.menu = menu
        rightMenuButton.showsMenuAsPrimaryAction = true
    }
    
    private func presentModal(viewController: InGamePlayMenuViewController) {

        viewController.modalPresentationStyle = .pageSheet
        present(viewController, animated: true)
    }
}

#warning("하단 부분은 맵을 초기화 하게 하는 부분이지만 일단 임시적으로 만든 코드이기 때문에 재 설정 요망")
extension SingleGamePlayViewController {
    private func bind() {
        resetButton.rx.tap.subscribe { [weak self] _ in
            self?.mapViewSetting()
        }
        .disposed(by: disposeBag)
    }
}

private extension MKMapView {
    func centerToLocation(
        _ location: CLLocation,
        regionRadius: CLLocationDistance = 1000
    ) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius
        )
        setRegion(coordinateRegion, animated: true)
    }
}
