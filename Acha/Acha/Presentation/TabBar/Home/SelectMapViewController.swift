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

class SelectMapViewController: UIViewController {
    
    private lazy var mapView = MKMapView().then {
        $0.delegate = self
    }
    
    private lazy var guideLabel = UILabel().then {
        $0.text = "땅을 선택해주세요"
        $0.textColor = .mainColor
        $0.font = UIFont.boldSystemFont(ofSize: 24)
    }
    
    lazy var locationManager = CLLocationManager().then {
        // desiredAccuracy는 위치의 정확도를 설정
        // 정확도 높으면 배터리 많이 닳음
        $0.desiredAccuracy = kCLLocationAccuracyBest
        $0.startUpdatingLocation()     // startUpdate를 해야 didUpdateLocation 메서드가 호출됨
        $0.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        getLocationUsagePermission()
        setUpMapView()
    }
    
    // 뷰가 화면에서 사라질 때 locationManager가 위치 업데이트를 중단하도록 설정
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
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
    }
}

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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // 현재 위치(경도, 위도) 얻어오기
        guard let location = locations.last else { return }
        let latitude = location.coordinate.latitude
        let longtitude = location.coordinate.longitude
        
        // 사용자의 현재 위치에 지도 focus 설정
        let center = CLLocationCoordinate2D(latitude: latitude,
                                            longitude: longtitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        
        // MKOverlayRenderer를 이용하여 지도 위에 이동 기록 표시
//        if let previousCoordinate = previousCoordinate {
//            var points: [CLLocationCoordinate2D] = []
//            let point1 = CLLocationCoordinate2D(latitude: previousCoordinate.latitude,
//                                                longitude: previousCoordinate.longitude)
//            let point2 = CLLocationCoordinate2D(latitude: latitude,
//                                                longitude: longtitude)
//            points.append(contentsOf: [point1, point2])
//
//            let lineDraw = MKPolyline(coordinates: points, count: points.count)
//            mapView.addOverlay(lineDraw)
//        }
//
//        previousCoordinate = location.coordinate
    }
}

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
        // 내 위치 기준으로 지도 움직이도록 설정
        mapView.setUserTrackingMode(.follow, animated: true)
    }
    
    /// mapView.addOverlay(lineDraw) 실행 시 호출되는 함수
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyLine = overlay as? MKPolyline
        else {
            print("polyline을 그릴 수 없음")
            return MKOverlayRenderer()
        }
        
        let renderer = MKPolylineRenderer(polyline: polyLine)
        renderer.strokeColor = .red
        renderer.lineWidth = 5.0
        renderer.alpha = 1.0
        
        return renderer
    }
}