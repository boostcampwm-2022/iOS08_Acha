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
                    ColorConstants.pointColor ?? UIColor(),
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
                    ColorConstants.pointColor ?? UIColor(),
                    renderingMode: .alwaysOriginal
                ),
            for: .normal
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let firstLoction = CLLocation(latitude: 37.517496, longitude: 126.959118)
    private let distanceAndTimeView: UIView = {
        let view = UIView()
        return view
    }()
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        distanceAndTimeBarBottomLineAdjust(color: .white, width: 5)
        distanceAndTimeBarMiddleLineAdjust(color: .white, width: 5)
    }
}

// MARK: - Helpers
extension SingleGamePlayViewController {
    private func layout() {
        addViews()
        layoutViews()
        bind()
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
            rightMenuButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50),
            
            distanceAndTimeBar.widthAnchor.constraint(equalTo: view.widthAnchor),
            distanceAndTimeBar.heightAnchor.constraint(equalToConstant: 100),
            distanceAndTimeBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            resetButton.bottomAnchor.constraint(equalTo: distanceAndTimeBar.topAnchor),
            resetButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
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
