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
import RxSwift
import RxRelay

protocol MapBaseViewProtocol {
    var mapView: MKMapView { get set }
    var locationService: DefaultLocationService { get set }
//    var locationManager: CLLocationManager { get set }
    var focusButton: UIButton { get set }
    
    func configureMapViewUI()
//    func getLocationUsagePermission()
    func focusUserLocation(useSpan: Bool)
    func setUpMapView()
}

class MapBaseViewController: UIViewController, MapBaseViewProtocol {
    
    // MARK: - UI properties
    lazy var mapView: MKMapView = MKMapView().then {
        $0.delegate = self
    }
    
    // MARK: - Properties
    var locationService = DefaultLocationService()
    //    lazy var locationManager = CLLocationManager().then {
    //        // desiredAccuracy는 위치의 정확도를 설정 (정확도 높으면 배터리 많이 닳음)
    //        $0.desiredAccuracy = kCLLocationAccuracyBest
    //        $0.startUpdatingLocation()
    //        $0.delegate = self
    //
    //        $0.showsBackgroundLocationIndicator = true
    //        $0.allowsBackgroundLocationUpdates = true
    //    }
    
    lazy var focusButton = UIButton().then {
        $0.setImage(SystemImageNameSpace.locationCircle.uiImage, for: .normal)
        $0.tintColor = .pointLight
        $0.addTarget(self, action: #selector(focusButtonDidClick), for: .touchDown)
        
        // button image size 설정
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40)
        $0.setPreferredSymbolConfiguration(imageConfig, forImageIn: .normal)
    }
    
    var disposeBags = DisposeBag()
    let location = BehaviorRelay<CLLocation>(value: CLLocation(latitude: 37.0, longitude: 126.0))
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapViewUI()
        setUpMapView()
        locationService.start()
        bindLocationService()
        //        getLocationUsagePermission()
    }
    
    // 뷰가 화면에서 사라질 때 locationManager가 위치 업데이트를 중단하도록 설정
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        locationService.stop()
        //        locationManager.stopUpdatingLocation()
        mapView.delegate = nil
        mapView.removeFromSuperview()
        //        locationManager.delegate = nil
    }
    
    func bindLocationService() {
        locationService.authorizationStatus
            .subscribe(onNext: { [weak self] authorizationStatus in
                guard let self else { return }
                if authorizationStatus {
                    self.setUpUserLocation()
                } else {
                    self.showAlertToMoveSetting()
                }
            })
            .disposed(by: disposeBags)
        
        locationService.observeLocation()
            .subscribe(onNext: { [weak self] location in
                guard let self else { return }
                self.location.accept(location)
            })
            .disposed(by: disposeBags)
    }
    
    // MARK: - Helpers
    func configureMapViewUI() {
        view.addSubview(mapView)
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setUpMapView() {
        // 어플을 종료하고 다시 실행했을 때 MapKit이 발생할 수 있는 오류를 방지하기 위한 처리
        if #available(iOS 16.0, *) {
            mapView.preferredConfiguration = MKStandardMapConfiguration()
        } else {
            mapView.mapType = .standard
        }
        
        mapView.showsCompass = false
    }
}

extension MapBaseViewController {
    
    /// center 좌표에 span 0.01 수준으로 지도 포커스
    func focusMapLocation(center: CLLocationCoordinate2D, span: Double = 0.01) {
        let region = MKCoordinateRegion(center: center,
                                        span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span))
        mapView.setRegion(region, animated: true)
    }
    
    @objc func focusButtonDidClick(_ sender: UIButton) {
        focusUserLocation(useSpan: false)
    }
    
    func setUpUserLocation() {
//        locationManager.startUpdatingLocation()
        print(#function)
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
        focusUserLocation(useSpan: true)
    }
    
    
    func focusUserLocation(useSpan: Bool) {
        if useSpan {
            focusMapLocation(center: location.value.coordinate)
        } else {
            mapView.setCenter(location.value.coordinate, animated: true)
        }
    }
}

extension MapBaseViewController {
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
