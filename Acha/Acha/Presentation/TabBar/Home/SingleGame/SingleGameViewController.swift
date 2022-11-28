//
//  SingleViewController.swift
//  Acha
//
//  Created by 조승기 on 2022/11/16.
//

import UIKit
import MapKit
import Then
import SnapKit
import RxSwift
import RxRelay
import RxCocoa

class SingleGameViewController: MapBaseViewController, DistanceAndTimeBarLine {
    // MARK: - UI properties
    private lazy var resetButton: UIButton = UIButton().then {
        $0.setImage(
            ImageConstants
                .arrowPositionResetImage?
                .withTintColor(
                    .pointLight,
                    renderingMode: .alwaysOriginal),
            for: .normal
        )
    }
    var distanceAndTimeBar = DistanceAndTimeBar()
    private lazy var rightMenuButton: UIButton = UIButton().then {
        $0.setImage(
            ImageConstants.inGameMenuButtonImage?
                .withTintColor(
                    .pointLight,
                    renderingMode: .alwaysOriginal
                ),
            for: .normal
        )
    }
    private lazy var gameOverButton = UIButton().then {
        $0.setTitle("게임 종료", for: .normal)
        $0.tintColor = .white
        $0.backgroundColor = .pointLight
        $0.layer.cornerRadius = 10
    }
    // MARK: - Properties
    private let viewModel: SingleGameViewModel!
    private let disposeBag = DisposeBag()

    let realGameOverButtonTappedEvent = PublishRelay<Void>()
    let rankButtonTappedEvent = PublishRelay<Void>()
    let recordButtonTappedEvent = PublishRelay<Void>()
    let mapTappedEvent = PublishRelay<Void>()
    
    var goLine: MKPolyline?
    var wentLine: MKPolyline?
    var visitLine: MKPolyline?
    
    // MARK: - Lifecycles
    init(viewModel: SingleGameViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        configureMap()
        bind()
    }
    
    deinit {
        presentedViewController?.dismiss(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureDistanceAndTimeBarBottomUI()
    }
    
    private func configureDistanceAndTimeBarBottomUI() {
        distanceAndTimeBarBottomLineAdjust(color: UIColor.white, width: 3)
        distanceAndTimeBarMiddleLineAdjust(color: UIColor.white, width: 3)
    }
}

// MARK: - Helpers
extension SingleGameViewController {
    private func setupSubviews() {
        [rightMenuButton, distanceAndTimeBar, resetButton, gameOverButton]
            .forEach {
                view.addSubview($0)
            }
        rightMenuButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.height.width.equalTo(50)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-10)
        }
        distanceAndTimeBar.snp.makeConstraints {
            $0.width.equalTo(view.snp.width)
            $0.height.equalTo(100)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        resetButton.snp.makeConstraints {
            $0.bottom.equalTo(distanceAndTimeBar.snp.top).offset(-10)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-10)
            $0.width.height.equalTo(50)
        }
        gameOverButton.snp.makeConstraints {
            $0.bottom.equalTo(distanceAndTimeBar.snp.top).offset(-30)
            guard let mapView else { return }
            $0.centerX.equalTo(mapView)
            $0.width.equalTo(100)
            $0.height.equalTo(40)
        }
        
        rightMenuButtonSetting()
    }
    
    private func rightMenuButtonSetting() {
        let menuItems: [UIAction] =
        [
            UIAction(title: "랭킹", handler: { [weak self] _ in
                guard let self else { return }
                self.rankButtonTappedEvent.accept(())
            }),
            UIAction(title: "기록", handler: { [weak self] _ in
                guard let self else { return }
                self.recordButtonTappedEvent.accept(())
            })
        ]
        let menu = UIMenu(title: "", children: menuItems)
        rightMenuButton.menu = menu
        rightMenuButton.showsMenuAsPrimaryAction = true
    }
    
    private func configureMap() {
        drawGoLine()
        configureMapTapped()
    }
    private func drawGoLine() {
        let points = viewModel.map.coordinates.map {
            CLLocationCoordinate2DMake($0.latitude, $0.longitude)
        }
        
        let lineDraw = MKPolyline(coordinates: points, count: points.count)
        goLine = lineDraw
        mapView?.addOverlay(goLine ?? MKPolyline())
    }
    
    func configureMapTapped() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(mapViewTapped(_:)))
        mapView?.addGestureRecognizer(tap)
    }
    
    @objc func mapViewTapped(_ sender: UITapGestureRecognizer) {
        mapTappedEvent.accept(())
    }
    
    private func bind() {
        let input = SingleGameViewModel.Input(
            gameOverButtonTapped: realGameOverButtonTappedEvent.asObservable(),
            rankButtonTapped: rankButtonTappedEvent.asObservable(),
            recordButtonTapped: recordButtonTappedEvent.asObservable(),
            mapTapped: mapTappedEvent.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output.runningDistance
            .asDriver(onErrorJustReturn: 0.0)
            .drive(onNext: { [weak self] distance in
                self?.distanceAndTimeBar.distanceLabel.text = distance.meterToKmString
            })
            .disposed(by: disposeBag)
        output.runningTime
            .asDriver(onErrorJustReturn: 1)
            .drive(onNext: { [weak self] time in
                self?.distanceAndTimeBar.timeLabel.text = "\(time)초"
            }).disposed(by: disposeBag)
        
        output.wentLocations
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] coordinates in
                self?.drawWentLine(coordiates: coordinates.map { CLLocationCoordinate2D.from(coordiate: $0) })
            }).disposed(by: disposeBag)
        
        output.visitLocations
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] coordinates in
                self?.drawVisitLine(coordiates: coordinates.map { CLLocationCoordinate2D.from(coordiate: $0)})
            }).disposed(by: disposeBag)
        
        output.ishideGameOverButton
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isHide in
                self?.gameOverButton.isHidden = isHide
            }).disposed(by: disposeBag)
        
        bindButtons()
    }
    
    private func bindButtons() {
        resetButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.focusUserLocation(useSpan: false)
            }).disposed(by: disposeBag)
    }
    
    func drawWentLine(coordiates: [CLLocationCoordinate2D]) {
        wentLine = MKPolyline(coordinates: coordiates, count: coordiates.count)
        mapView?.addOverlay(wentLine ?? MKPolyline())
    }
    
    func drawVisitLine(coordiates: [CLLocationCoordinate2D]) {
        visitLine = MKPolyline(coordinates: coordiates, count: coordiates.count)
        mapView?.addOverlay(visitLine ?? MKPolyline())
    }
}

// MARK: - MKMapViewDelegate
extension SingleGameViewController {
    // mapView.addOverlay(lineDraw) 실행 시 호출되는 함수
    override func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyLine = overlay as? MKPolyline
        else {
            print("polyline을 그릴 수 없음")
            return MKOverlayRenderer()
        }
        
        let renderer = MKPolylineRenderer(polyline: polyLine)
        renderer.lineWidth = 5.0
        renderer.alpha = 1.0
        
        if overlay as? MKPolyline == wentLine {
            renderer.strokeColor = .red
        } else if overlay as? MKPolyline == goLine {
            renderer.strokeColor = .lightGray
        } else if overlay as? MKPolyline == visitLine {
            renderer.strokeColor = .blue
        }
        
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isEqual(mapView.userLocation) {
            let penguinView = MKAnnotationView(annotation: annotation, reuseIdentifier: "userLocation")
            penguinView.image = UIImage(named: "penguin")
            return penguinView
        }
        return nil
    }
}
