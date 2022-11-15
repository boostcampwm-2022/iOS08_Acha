//
//  SingleGameViewController.swift
//  Acha
//
//  Created by 조승기 on 2022/11/15.
//

import UIKit
import MapKit
import Then
import SnapKit
import RxSwift
import RxRelay

class SingleGameViewController: UIViewController {
    // MARK: - UI properties
    private let mapView: MKMapView = MKMapView().then {
        $0.setUserTrackingMode(.followWithHeading, animated: true)
        $0.showsUserLocation = true
        $0.setUserTrackingMode(.followWithHeading, animated: true)
        $0.showsCompass = false
    }
    
    private let distanceLabel: UILabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.textAlignment = .center
    }
    
    // MARK: - Properties
    private let viewModel: SingleGameViewModel!
    private let disposeBag = DisposeBag()
    private lazy var locationManager: CLLocationManager = CLLocationManager().then {
        $0.desiredAccuracy = kCLLocationAccuracyBest
        $0.startUpdatingLocation()
        $0.delegate = self
    }
    
    var previousCoordinate: CLLocationCoordinate2D?
    var goLine: MKPolyline?
    var wentLine: MKPolyline?
    private let currentUserCoordinate = PublishRelay<CLLocationCoordinate2D>()
    
    // MARK: - Lifecycles
    init(viewModel: SingleGameViewModel!) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        setupSubviews()
        configureMap()
        configureLocationManager()
        drawGoLine()
        bind()
    }
    
    // MARK: - Helpers
    private func setupSubviews() {
        [mapView, distanceLabel].forEach { view.addSubview($0) }
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        distanceLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func configureMap() {
        mapView.delegate = self
        
        let centerLocation = CLLocationCoordinate2D(
            latitude: 37.4979534,
            longitude: 126.7244298
        )
        
        let span = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
        let region = MKCoordinateRegion(center: centerLocation, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    private func configureLocationManager() {
        
    }
    
    private func drawGoLine() {
        viewModel.mapCoordinates
            .subscribe(onNext: { [weak self] thisMap in
                guard let self else { return }
                print("@@@@@@@", thisMap.coordinates.count)
                let points = thisMap.coordinates.map {
                    CLLocationCoordinate2DMake($0.latitude, $0.longitude)
                }
                
                let lineDraw = MKPolyline(coordinates: points, count: points.count)
                self.wentLine = lineDraw
                self.mapView.addOverlay(self.wentLine ?? MKPolyline())
            }).disposed(by: disposeBag)
    }
    
    private func bind() {
        viewModel.fetchAllMaps()
        
        viewModel.movedDistance
            .subscribe(onNext: { [weak self] distance in
                guard let self else { return }
                let kmString = String(format: "%.2f", distance/1000)
                self.distanceLabel.text = "\(kmString)km"
            }).disposed(by: disposeBag)
    }
}

extension SingleGameViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            print("GPS 권한 설정됨")
            locationManager.startUpdatingLocation()
        case .restricted, .notDetermined:
            print("GPS 권한 설정되지 않음")
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            print("GPS 권한 요청 거부됨")
            locationManager.requestWhenInUseAuthorization()
        default:
            print("GPS: Default")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        if let previous = previousCoordinate {
            drawGoLine(from: previous, here: location.coordinate)
            viewModel.userMoved(
                coordinate: Coordinate(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude),
                distance: previous.distance(to: location.coordinate)
            )
        }
        
        self.previousCoordinate = location.coordinate
        setMapRegion(toCoordinate: location.coordinate)
    }
    
    func setMapRegion(toCoordinate coordinate: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func drawGoLine(from: CLLocationCoordinate2D, here: CLLocationCoordinate2D) {
        let lineDraw = MKPolyline(coordinates: [from, here], count: 2)
        goLine = lineDraw
        self.mapView.addOverlay(goLine ?? MKPolyline())
    }
}

extension SingleGameViewController: MKMapViewDelegate {
    // mapView.addOverlay(lineDraw) 실행 시 호출되는 함수
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyLine = overlay as? MKPolyline
        else {
            print("polyline을 그릴 수 없음")
            return MKOverlayRenderer()
        }
        
        let renderer = MKPolylineRenderer(polyline: polyLine)
        renderer.lineWidth = 5.0
        renderer.alpha = 1.0
        
        if overlay as? MKPolyline == wentLine {
            renderer.strokeColor = .lightGray
        } else if overlay as? MKPolyline == goLine {
            renderer.strokeColor = .red
        }
        
        return renderer
    }
}