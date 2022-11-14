//
//  SelectMapViewController.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/14.
//

import UIKit
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

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setUpMapView()
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

extension SelectMapViewController: MKMapViewDelegate {
    
    private func setUpMapView() {
        // 어플을 종료하고 다시 실행했을 때 MapKit이 발생할 수 있는 오류를 방지하기 위한 처리
        if #available(iOS 16.0, *) {
            mapView.preferredConfiguration = MKStandardMapConfiguration()
        } else {
            mapView.mapType = .standard
        }
    }
}
