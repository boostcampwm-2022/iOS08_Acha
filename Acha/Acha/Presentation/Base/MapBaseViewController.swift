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
    var mapView: MKMapView? { get set }
    var locationManager: CLLocationManager? { get set }
    var focusButton: UIButton { get set }
    
    func configureMapViewUI()
    func getLocationUsagePermission()
    func focusUserLocation(useSpan: Bool)
    func setUpMapView()
}

class MapBaseViewController: UIViewController, MapBaseViewProtocol {
    
    // MARK: - UI properties
    lazy var mapView: MKMapView? = MKMapView().then {
        $0.delegate = self
    }
    
    // MARK: - Properties
    lazy var locationManager: CLLocationManager? = CLLocationManager().then {
        // desiredAccuracy는 위치의 정확도를 설정 (정확도 높으면 배터리 많이 닳음)
        $0.desiredAccuracy = kCLLocationAccuracyBest
        $0.startUpdatingLocation()
        $0.delegate = self
        
        $0.showsBackgroundLocationIndicator = true
        $0.allowsBackgroundLocationUpdates = true
    }
    
    lazy var focusButton = UIButton().then {
        $0.setImage(SystemImageNameSpace.locationCircle.uiImage, for: .normal)
        $0.tintColor = .pointLight
        $0.addTarget(self, action: #selector(focusButtonDidClick), for: .touchDown)
        
        // button image size 설정
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40)
        $0.setPreferredSymbolConfiguration(imageConfig, forImageIn: .normal)
    }
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapViewUI()
        setUpMapView()
        getLocationUsagePermission()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let mapView {
            mapView.removeAnnotations(mapView.annotations)
        }
        mapView?.removeFromSuperview()
        mapView?.delegate = nil
        mapView = nil
        locationManager?.stopUpdatingLocation()
        locationManager?.delegate = nil
        locationManager = nil
    }
    
    // MARK: - Helpers
    func configureMapViewUI() {
        guard let mapView else { return }
        view.addSubview(mapView)
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setUpMapView() {
        // 어플을 종료하고 다시 실행했을 때 MapKit이 발생할 수 있는 오류를 방지하기 위한 처리
        if #available(iOS 16.0, *) {
            mapView?.preferredConfiguration = MKStandardMapConfiguration()
        } else {
            mapView?.mapType = .standard
        }
        mapView?.showsCompass = false
    }
}

extension MapBaseViewController {
    
    /// center 좌표에 span 0.01 수준으로 지도 포커스
    func focusMapLocation(center: CLLocationCoordinate2D, span: Double = 0.01) {
        let region = MKCoordinateRegion(center: center,
                                        span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span))
        mapView?.setRegion(region, animated: true)
    }
    
    @objc func focusButtonDidClick(_ sender: UIButton) {
        focusUserLocation(useSpan: false)
    }
    
    func setUpUserLocation() {
        locationManager?.startUpdatingLocation()
        mapView?.showsUserLocation = true
        mapView?.setUserTrackingMode(.followWithHeading, animated: true)
        focusUserLocation(useSpan: true)
    }
    
    func getLocationUsagePermission() {
        locationManager?.requestWhenInUseAuthorization()
    }
    
    func focusUserLocation(useSpan: Bool) {
        guard let userLocation = locationManager?.location else { return }
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude,
                                            longitude: userLocation.coordinate.longitude)
        if useSpan {
            focusMapLocation(center: center)
        } else {
            mapView?.setCenter(center, animated: true)
        }
    }
}

extension MapBaseViewController: CLLocationManagerDelegate {
    
    /// GPS 권한 설정 여부에 따라 로직 분리
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            print("GPS 권한 설정됨")
            setUpUserLocation()
        case .restricted, .notDetermined:
            print("GPS 권한 설정되지 않음")
            getLocationUsagePermission()
        case .denied:
            print("GPS 권한 요청 거부됨")
            showAlertToMoveSetting()
        default:
            print("GPS: Default")
        }
    }
    
    private func showAlertToMoveSetting() {
        let alert = UIAlertController(title: "위치 서비스를 사용할 수 없습니다. 기기의 '설정 > 개인정보 보호'에서 위치 서비스를 켜주세요.",
                                      message: nil,
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .default, handler: { _ in
            // TODO: 홈화면이나 이전 화면으로 이동
        })
        let moveSettingsAction = UIAlertAction(title: "설정으로 이동", style: .cancel, handler: { _ in
            guard let settingURL = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingURL)
        })
        alert.addAction(cancelAction)
        alert.addAction(moveSettingsAction)
        present(alert, animated: true)
    }
}

// MARK: - MKMapViewDelegate
extension MapBaseViewController: MKMapViewDelegate {
    
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
