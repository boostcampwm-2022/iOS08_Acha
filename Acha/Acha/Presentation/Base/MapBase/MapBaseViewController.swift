//
//  MapBaseViewController.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/15.
//
import UIKit
import Then
import MapKit
import RxSwift
import RxRelay

protocol MapBaseViewProtocol {
    var mapView: MKMapView? { get set }
    var focusButton: UIButton { get set }
    var disposeBag: DisposeBag { get set }
    
    func setUpMapView()
    func focusMapLocation(center: CLLocationCoordinate2D, span: Double)
    func focusUserLocation(location: Coordinate, useSpan: Bool)
}

class MapBaseViewController: UIViewController, MapBaseViewProtocol {
    // MARK: - UI properties
    lazy var mapView: MKMapView? = MKMapView().then {
        $0.delegate = self
    }
    
    lazy var focusButton = UIButton().then {
        $0.setImage(SystemImageNameSpace.locationCircle.uiImage, for: .normal)
        $0.tintColor = .pointLight
        // button image size 설정
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40)
        $0.setPreferredSymbolConfiguration(imageConfig, forImageIn: .normal)
    }
    
    // MARK: - Properties
    let mapBaseViewModel: MapBaseViewModel
    var disposeBag = DisposeBag()
    
    // MARK: - Lifecycles
    init(viewModel: MapBaseViewModel) {
        self.mapBaseViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMapView()
        bind()
    }
    
    // 뷰가 화면에서 사라질 때 locationManager가 위치 업데이트를 중단하도록 설정
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mapView?.delegate = nil
        mapView?.removeFromSuperview()
    }
    
    // MARK: - Helpers
    func setUpMapView() {
        guard let mapView else { return }
        if #available(iOS 16.0, *) {
            mapView.preferredConfiguration = MKStandardMapConfiguration()
        } else {
            mapView.mapType = .standard
        }
        mapView.showsCompass = false
    }
    
    private func bind() {
        let input = MapBaseViewModel.Input(
            viewWillDisappearEvent: rx.methodInvoked(#selector(UIViewController.viewWillDisappear)).map { _ in },
            focusButtonTapped: focusButton.rx.tap.asObservable())
        let output = mapBaseViewModel.transform(input: input)
        
        output.focusUserEvent.subscribe(onNext: { [weak self] userLocation in
            guard let self else { return }
            self.focusUserLocation(location: userLocation, useSpan: false)
        })
        .disposed(by: disposeBag)
        
        output.isAvailableLocationAuthorization
            .subscribe(onNext: { [weak self] (isAvailable, userLocation) in
                guard let self else { return }
                if isAvailable {
                    guard let userLocation else { return }
                    self.setUpUserLocation(userLocation)
                } else {
                    self.showAlertToMoveSetting()
                }
            })
            .disposed(by: disposeBag)
    }
}

extension MapBaseViewController {
    
    private func setUpUserLocation(_ location: Coordinate) {
        mapView?.showsUserLocation = true
        mapView?.setUserTrackingMode(.followWithHeading, animated: true)
        focusUserLocation(location: location, useSpan: true)
    }
    
    /// center 좌표에 span 0.01 수준으로 지도 포커스
    func focusMapLocation(center: CLLocationCoordinate2D, span: Double = 0.01) {
        let region = MKCoordinateRegion(center: center,
                                        span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span))
        mapView?.setRegion(region, animated: true)
    }
    
    func focusUserLocation(location: Coordinate, useSpan: Bool) {
        let clLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        if useSpan {
            focusMapLocation(center: clLocation)
        } else {
            mapView?.setCenter(clLocation, animated: true)
        }
    }
}

extension MapBaseViewController {
    #warning("showAlert으로 고치려고 했는데 showAlert에는 취소 액션이 없네여 추가하고 그거 쓰면 좋을 듯합니다")
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
