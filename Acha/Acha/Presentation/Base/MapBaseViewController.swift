//
//  MapBaseViewController.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/15.
//

import UIKit
import CoreLocation
import Then
import MapKit

protocol MapBaseViewProtocol {
    var mapView: MKMapView { get set }
    var locationManager: CLLocationManager { get set }
    
    func configureMapViewUI()
    func getLocationUsagePermission()
    func focusUserLocation(useSpan: Bool)
    func setUpMapView()
}

class MapBaseViewController: UIViewController, MapBaseViewProtocol {
    
    // MARK: - UI properties
    lazy var mapView = MKMapView().then {
        $0.delegate = self
    }
    
    // MARK: - Properties
    lazy var locationManager = CLLocationManager().then {
        // desiredAccuracy는 위치의 정확도를 설정 (정확도 높으면 배터리 많이 닳음)
        $0.desiredAccuracy = kCLLocationAccuracyBest
        $0.startUpdatingLocation()
        $0.delegate = self
        
        $0.showsBackgroundLocationIndicator = true
        $0.allowsBackgroundLocationUpdates = true
    }
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapViewUI()
        setUpMapView()
    }
    
    // 뷰가 화면에서 사라질 때 locationManager가 위치 업데이트를 중단하도록 설정
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Helpers
    func configureMapViewUI() {
        view.addSubview(mapView)
        mapView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    /// center 좌표에 span 0.01 수준으로 지도 포커스
    func focusMapLocation(center: CLLocationCoordinate2D, span: Double = 0.01) {
        let region = MKCoordinateRegion(center: center,
                                        span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span))
        mapView.setRegion(region, animated: true)
    }
}

extension MapBaseViewController: CLLocationManagerDelegate {
    
    /// GPS 권한 설정 여부에 따라 로직 분리
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            print("GPS 권한 설정됨")
            locationManager.startUpdatingLocation()
            focusUserLocation(useSpan: true)
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
    
    func focusUserLocation(useSpan: Bool) {
        guard let userLocation = locationManager.location else { return }
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude,
                                            longitude: userLocation.coordinate.longitude)
        if useSpan {
            focusMapLocation(center: center)
        } else {
            mapView.setCenter(center, animated: true)
        }
    }
    
}

// MARK: - MKMapViewDelegate

extension MapBaseViewController: MKMapViewDelegate {
    
    func setUpMapView() {
        // 어플을 종료하고 다시 실행했을 때 MapKit이 발생할 수 있는 오류를 방지하기 위한 처리
        if #available(iOS 16.0, *) {
            mapView.preferredConfiguration = MKStandardMapConfiguration()
        } else {
            mapView.mapType = .standard
        }
        
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
        
        mapView.showsCompass = false
        focusUserLocation(useSpan: true)
        mapView.isRotateEnabled = false
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
}
