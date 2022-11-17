//
//  SigleViewController.swift
//  Acha
//
//  Created by 조승기 on 2022/11/16.
//

import UIKit
import MapKit
import Then
import SnapKit
import RxSwift
import RxRelay

class SigleViewController: MapBaseViewController, DistanceAndTimeBarLine {
    // MARK: - UI properties
    private lazy var resetButton: UIButton = UIButton().then {
        $0.setImage(
            ImageConstants
                .arrowPositionResetImage?
                .withTintColor(
                    .pointLight ?? UIColor.red,
                    renderingMode: .alwaysOriginal),
            for: .normal
        )
    }
    var distanceAndTimeBar = DistanceAndTimeBar()
    private lazy var rightMenuButton: UIButton = UIButton().then {
        $0.setImage(
            ImageConstants.inGameMenuButtonImage?
                .withTintColor(
                    .pointLight ?? UIColor.red,
                    renderingMode: .alwaysOriginal
                ),
            for: .normal
        )
    }
    // MARK: - Properties
    private let viewModel: SingleGameViewModel!
    private let disposeBag = DisposeBag()
    
    var goLine: MKPolyline?
    var wentLine: MKPolyline?
    var visitLine: MKPolyline?
    
    // MARK: - Lifecycles
    init(viewModel: SingleGameViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        configureMap()
        bind()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureDistanceAndTimeBarBottomUI()
    }
    
    private func configureDistanceAndTimeBarBottomUI() {
        distanceAndTimeBarBottomLineAdjust(color: UIColor.white, width: 3)
        distanceAndTimeBarMiddleLineAdjust(color: UIColor.white, width: 3)
    }
    
    override func configureUI() {
        super.configureUI()
        view.backgroundColor = .white
    }
}

// MARK: - Helpers
extension SigleViewController {
    private func setupSubviews() {
        [rightMenuButton, distanceAndTimeBar, resetButton]
            .forEach {
                view.addSubview($0)
            }
        rightMenuButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.height.width.equalTo(50)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-10)
        }
        distanceAndTimeBar.snp.makeConstraints {
            $0.width.equalTo(view.snp.width)
            $0.height.equalTo(100)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        resetButton.snp.makeConstraints {
            $0.bottom.equalTo(distanceAndTimeBar.snp.top).offset(-10)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-10)
            $0.width.height.equalTo(50)
        }
        rightMenuButtonSetting()
    }
    
    private func rightMenuButtonSetting() {
        let menuItems: [UIAction] =
        [
            UIAction(title: "랭킹", handler: { [weak self] _ in
                let viewController = GamePlayMenuViewController(type: .ranking)
                self?.presentModal(viewController: viewController)
            }),
            UIAction(title: "기록", handler: { [weak self] _ in
                let viewController = GamePlayMenuViewController(type: .recordHistory)
                self?.presentModal(viewController: viewController)
            })
        ]
        let menu = UIMenu(title: "", children: menuItems)
        rightMenuButton.menu = menu
        rightMenuButton.showsMenuAsPrimaryAction = true
    }
    
    private func presentModal(viewController: GamePlayMenuViewController) {
        viewController.modalPresentationStyle = .pageSheet
        present(viewController, animated: true)
    }
    
    private func configureMap() {
        drawGoLine()
    }
    
    private func drawGoLine() {
        let points = viewModel.map.coordinates.map {
            CLLocationCoordinate2DMake($0.latitude, $0.longitude)
        }
        
        let lineDraw = MKPolyline(coordinates: points, count: points.count)
        goLine = lineDraw
        mapView.addOverlay(goLine ?? MKPolyline())
    }
    
    private func bind() {
        resetButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.focusUserLocation(useSpan: false)
            }).disposed(by: disposeBag)
        
        viewModel.visitedMapCoordinates
            .subscribe(onNext: { [weak self] (previous, current) in
                guard let self,
                      let previous,
                      let current else { return }
                
                let previousCoordinate = CLLocationCoordinate2DMake(previous.latitude, previous.longitude)
                let currentCoordinate = CLLocationCoordinate2DMake(current.latitude, current.longitude)
                self.visitLine = MKPolyline(coordinates: [previousCoordinate, currentCoordinate], count: 2)
                self.mapView.addOverlay(self.visitLine ?? MKPolyline())
            }).disposed(by: disposeBag)
        
        viewModel.time
            .subscribe(onNext: { [weak self] time in
                guard let self else { return }
                self.distanceAndTimeBar.timeLabel.text = "\(time)초"
            }).disposed(by: disposeBag)
        
        viewModel.movedDistance
            .subscribe(onNext: { [weak self] distance in
                guard let self else { return }
                self.distanceAndTimeBar.distanceLabel.text = distance.meter2KmString
            }).disposed(by: disposeBag)
        
        viewModel.userMovedCoordinates
            .subscribe(onNext: { [weak self] (previous, current) in
                guard let self,
                      let previous,
                      let current else { return }
                
                let previousCoordinate = CLLocationCoordinate2DMake(previous.latitude, previous.longitude)
                let currentCoordinate = CLLocationCoordinate2DMake(current.latitude, current.longitude)
                self.wentLine = MKPolyline(coordinates: [previousCoordinate, currentCoordinate], count: 2)
                self.mapView.addOverlay(self.wentLine ?? MKPolyline())
            }).disposed(by: disposeBag)
        
    }
}

// MARK: - CLLocationManagerDelegate
extension SigleViewController {
    func locationManager( _ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        viewModel.currentCoordinate.accept(
            Coordinate(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        )
    }
    
    func setMapRegion(toCoordinate coordinate: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func drawWentLine(from: CLLocationCoordinate2D, here: CLLocationCoordinate2D) {
        wentLine = MKPolyline(coordinates: [from, here], count: 2)
        self.mapView.addOverlay(wentLine ?? MKPolyline())
    }
}

// MARK: - MKMapViewDelegate
extension SigleViewController {
    // mapView.addOverlay(lineDraw) 실행 시 호출되는 함수
    override func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyLine = overlay as? MKPolyline
        else {
            print("polyline을 그릴 수 없음")
            return MKOverlayRenderer()
        }
        
        let renderer = MKPolylineRenderer(polyline: polyLine)
        renderer.lineWidth = 5.0
        renderer.alpha = 1.0
        
        if overlay as? MKPolyline == wentLine {
            renderer.strokeColor = .red
        } else if overlay as? MKPolyline == goLine {
            renderer.strokeColor = .lightGray
        } else if overlay as? MKPolyline == visitLine {
            renderer.strokeColor = .blue
        }
        
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isEqual(mapView.userLocation) {
            let penguinView = MKAnnotationView(annotation: annotation, reuseIdentifier: "userLocation")
            penguinView.image = UIImage(named: "penguin")
            return penguinView
        }
        return nil
    }
}
