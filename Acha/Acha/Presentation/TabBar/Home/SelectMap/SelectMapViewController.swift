//
//  SelectMapViewController.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/14.
//

import UIKit
import CoreLocation
import MapKit
import Then
import SnapKit
import Firebase
import RxSwift

final class SelectMapViewController: MapBaseViewController {
    
    // MARK: - UI properties
    private lazy var guideLabel = UILabel().then {
        $0.text = "땅을 선택해주세요"
        $0.textColor = .pointLight
        $0.font = UIFont.boldSystemFont(ofSize: 24)
    }
    
    private lazy var startButton = UIButton().then {
        $0.setTitle("게임 시작", for: .normal)
        $0.tintColor = .white
        $0.backgroundColor = .pointLight
        $0.layer.cornerRadius = 10
        $0.isValid = false
    }
    
    private lazy var rankingView = UIView().then {
        $0.backgroundColor = .red
        $0.layer.cornerRadius = 15
        $0.isHidden = true
    }

    // MARK: - Properties
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
        viewModel.fetchAllMaps()
        bind()
    }
    
    // MARK: - Helpers
    func configureUI() {        
        view.addSubview(guideLabel)
        guideLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        view.addSubview(focusButton)
        focusButton.snp.makeConstraints {
            $0.top.equalTo(mapView.snp.top).offset(50)
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
}

// MARK: - MKMapViewDelegate

extension SelectMapViewController {
    
    /// annotation (=pin) 클릭 시 액션
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        rankingView.isHidden = false
        startButton.isValid = true
        
        // 테두리 색상 변경
        guard let annotation = annotation as? MapAnnotation else { return }
        let renderer = mapView.renderer(for: annotation.polyLine) as? MKPolylineRenderer
        renderer?.strokeColor = .red
        
        // 땅이 랭킹뷰 위쪽에 오도록 지도 포커스
        let center = CLLocationCoordinate2D(latitude: annotation.map.centerCoordinate.latitude - 0.003,
                                            longitude: annotation.map.centerCoordinate.longitude)
        focusMapLocation(center: center)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect annotation: MKAnnotation) {
        rankingView.isHidden = true
        startButton.isValid = false
        
        guard let annotation = annotation as? MapAnnotation else { return }
        let renderer = mapView.renderer(for: annotation.polyLine) as? MKPolylineRenderer
        renderer?.strokeColor = .gray
    }
}
