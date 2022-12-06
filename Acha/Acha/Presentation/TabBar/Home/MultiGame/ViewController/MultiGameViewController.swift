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
    }

}

extension MultiGameViewController {
    
    private func layout() {
        addViews()
        addConstraints()
    }
    
    private func addViews() {
        view.addSubview(distanceAndTimeBar)
        view.addSubview(mapView)
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
    }
    
}
