//
//  MultiGameViewController.swift
//  Acha
//
//  Created by hong on 2022/11/27.
//

import UIKit
import MapKit
import SnapKit
import RxSwift

final class MultiGameViewController: UIViewController, DistanceAndTimeBarLine {

    var distanceAndTimeBar: DistanceAndTimeBar = .init()
    
    private let mapView: MKMapView = .init()
    
    private let viewModel: MultiGameViewModel
    private let disposebag = DisposeBag()
    private lazy var exitButton = UIButton().then {
        $0.setImage(.exitImage, for: .normal)
    }
    
    init(viewModel: MultiGameViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        
        layout()
        bind()
    }
    
    func bind() {
        let inputs = MultiGameViewModel.Input(
            viewDidAppear: rx.viewDidAppear.asObservable()
        )
        let outputs = viewModel.transform(input: inputs)
        outputs.time
            .drive(onNext: { [weak self] time in
                self?.distanceAndTimeBar.timeLabel.text = "\(time)"
            })
            .disposed(by: disposebag)
        
        outputs.visitedLocation
            .drive(onNext: { [weak self] location in
                self?.mapView.addOverlay(MKCircle(center: location.coordinate, radius: 10))
                let annotation = PlayerAnnotation(player: MultiGamePlayerData(
                    id: "aewtew",
                    nickName: "AWettwe", currentLocation: Coordinate(latitude: location.coordinate.latitude,
                                                                     longitude: location.coordinate.longitude),
                    point: 30)
                )
                self?.removeAllAnnotations()
                self?.mapView.addAnnotation(annotation)
            })
            .disposed(by: disposebag)
    }

}

extension MultiGameViewController {
    
    private func layout() {
        addViews()
        addConstraints()
        mapView.delegate = self
    }
    
    private func addViews() {
        view.addSubview(distanceAndTimeBar)
        view.addSubview(mapView)
        view.addSubview(exitButton)
    }
    
    private func addConstraints() {
        distanceAndTimeBar.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(90)
        }
        
        mapView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(distanceAndTimeBar.snp.top)
        }
        
        exitButton.snp.makeConstraints {
            $0.leading.top.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.width.height.equalTo(40)
        }
    }
    
}

extension MultiGameViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
         guard let circelOverLay = overlay as? MKCircle else {return MKOverlayRenderer()}

         let circleRenderer = MKCircleRenderer(circle: circelOverLay)
         circleRenderer.strokeColor = .blue
         circleRenderer.fillColor = .blue
         circleRenderer.alpha = 0.2
         return circleRenderer
     }
    
    private func removeAllAnnotations() {
        let annotations = mapView.annotations.filter {
            $0 !== mapView.userLocation
        }
        mapView.removeAnnotations(annotations)
    }
}
