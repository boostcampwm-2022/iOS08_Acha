//
//  SelectMapViewController.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/14.
//

import UIKit
import CoreLocation     // 사용자 위치 정보 받아오기 위함
import MapKit
import Then
import SnapKit
import Firebase
import RxSwift

final class SelectMapViewController: UIViewController {
    
    // MARK: - UI properties
    private lazy var mapView = MKMapView().then {
        $0.delegate = self
    }
    
    private lazy var guideLabel = UILabel().then {
        $0.text = "땅을 선택해주세요"
        $0.textColor = .pointColor
        $0.font = UIFont.boldSystemFont(ofSize: 24)
    }
    
    private lazy var focusButton = UIButton().then {
        $0.setImage(SystemImageNameSpace.locationCircle.uiImage, for: .normal)
        $0.tintColor = .pointColor
        $0.addTarget(self, action: #selector(focusButtonDidClick), for: .touchDown)
        
        // button image size 설정
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40)
        $0.setPreferredSymbolConfiguration(imageConfig, forImageIn: .normal)
    }
    
    private lazy var startButton = UIButton().then {
        $0.setTitle("게임 시작", for: .normal)
        $0.tintColor = .white
        $0.backgroundColor = .pointColor
        $0.layer.cornerRadius = 10
        $0.isEnabled(false)
    }
    
    private lazy var rankingView = UIView().then {
        $0.backgroundColor = .red
        $0.layer.cornerRadius = 15
        $0.isHidden = true
    }

    // MARK: - Properties
    private var ref: DatabaseReference!     // ref는 내 데이터베이스의 주소가 저장될 변수
    private lazy var locationManager = CLLocationManager().then {
        // desiredAccuracy는 위치의 정확도를 설정 (정확도 높으면 배터리 많이 닳음)
        $0.desiredAccuracy = kCLLocationAccuracyBest
        $0.startUpdatingLocation()     // startUpdate를 해야 didUpdateLocation 메서드가 호출됨
        $0.delegate = self
    }
    private let viewModel: SelectMapViewModel
    private var disposeBag = DisposeBag()
    
    // MARK: - Lifecycles
    init(viewModel: SelectMapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        getLocationUsagePermission()
        setUpMapView()
        viewModel.fetchAllMaps()
        bind()
    }
    
    // 뷰가 화면에서 사라질 때 locationManager가 위치 업데이트를 중단하도록 설정
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.addSubview(mapView)
        mapView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        view.addSubview(guideLabel)
        guideLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        view.addSubview(focusButton)
        focusButton.snp.makeConstraints {
            $0.top.equalTo(mapView.snp.top).offset(15)
            $0.trailing.equalTo(mapView.snp.trailing).offset(-15)
            $0.width.height.equalTo(40)
        }
        
        view.addSubview(startButton)
        startButton.snp.makeConstraints {
            $0.bottom.equalTo(mapView.snp.bottom).offset(-60)
            $0.centerX.equalTo(mapView)
            $0.width.equalTo(100)
            $0.height.equalTo(40)
        }
        
        view.addSubview(rankingView)
        rankingView.snp.makeConstraints {
            $0.bottom.equalTo(startButton.snp.top).offset(-30)
            $0.leading.trailing.equalTo(mapView).inset(20)
            $0.height.equalTo(300)
        }
    }
    
    private func bind() {
        viewModel.mapCoordinates
            .subscribe(onNext: { [weak self] maps in
                maps.forEach { mapElement in
                    let coordinates = mapElement.coordinates.map {
                        CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
                    }
                    
                    // 테두리 선
                    let lineDraw = MKPolyline(coordinates: coordinates, count: coordinates.count)
                    self?.mapView.addOverlay(lineDraw)
                    
                    // pin
                    let annotation = MapAnnotation(map: mapElement, polyLine: lineDraw)
                    self?.mapView.addAnnotation(annotation)
                }
            }).disposed(by: disposeBag)
    }
    
    @objc func focusButtonDidClick(_ sender: UIButton) {
        focusUserLocation(useSpan: false)
    }
}

// MARK: - CLLocationManagerDelegate

extension SelectMapViewController: CLLocationManagerDelegate {
    
    /// GPS 권한 설정 여부에 따라 로직 분리
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            print("GPS 권한 설정됨")
            locationManager.startUpdatingLocation()
        case .restricted, .notDetermined:
            print("GPS 권한 설정되지 않음")
            getLocationUsagePermission()
        case .denied:
            print("GPS 권한 요청 거부됨")
            getLocationUsagePermission()
        default:
            print("GPS: Default")
        }
    }
    
    func getLocationUsagePermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//    }
    
    /// 사용자 현위치에 폭 0.01 수준으로 지도 포커스
    private func focusUserLocation(useSpan: Bool) {
        guard let userLocation = locationManager.location else { return }
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude,
                                            longitude: userLocation.coordinate.longitude)
        if useSpan {
            let region = MKCoordinateRegion(center: center,
                                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            mapView.setRegion(region, animated: true)
        } else {
            mapView.setCenter(center, animated: true)
        }
    }
}

// MARK: - MKMapViewDelegate

extension SelectMapViewController: MKMapViewDelegate {
    
    private func setUpMapView() {
        // 어플을 종료하고 다시 실행했을 때 MapKit이 발생할 수 있는 오류를 방지하기 위한 처리
        if #available(iOS 16.0, *) {
            mapView.preferredConfiguration = MKStandardMapConfiguration()
        } else {
            mapView.mapType = .standard
        }
        
        // 지도에 내 위치 표시
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        // 내 위치 기준으로 지도 움직이도록 설정
        mapView.setUserTrackingMode(.follow, animated: true)
        
        focusUserLocation(useSpan: true)
    }
    
    /// mapView.addOverlay(lineDraw) 실행 시 호출되는 함수
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyLine = overlay as? MKPolyline
        else {
            print(Errors.cannotDrawPolyLine)
            return MKOverlayRenderer()
        }
        
        let renderer = MKPolylineRenderer(polyline: polyLine)
        renderer.strokeColor = .gray
        renderer.lineWidth = 5.0
        renderer.alpha = 1.0
        
        return renderer
    }
    
    /// pin 클릭 시 액션
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        rankingView.isHidden = false
        guard let annotation = annotation as? MapAnnotation else { return }
        let renderer = mapView.renderer(for: annotation.polyLine) as? MKPolylineRenderer
        renderer?.strokeColor = .red
    }
    
    /// pin 클릭 해제 시 액션
    func mapView(_ mapView: MKMapView, didDeselect annotation: MKAnnotation) {
        rankingView.isHidden = true
        guard let annotation = annotation as? MapAnnotation else { return }
        let renderer = mapView.renderer(for: annotation.polyLine) as? MKPolylineRenderer
        renderer?.strokeColor = .gray
    }
}
