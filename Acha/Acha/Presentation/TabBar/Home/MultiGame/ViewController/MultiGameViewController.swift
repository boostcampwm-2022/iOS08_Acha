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
import Then

final class MultiGameViewController: UIViewController, DistanceAndTimeBarLine {
    
    enum Section {
        case ranking
    }

    var distanceAndTimeBar: DistanceAndTimeBar = .init()
    private lazy var pointLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = .largeTitle
        $0.textColor = .black
    }
    private lazy var exitButton = UIButton().then {
        $0.setImage(.exitImage, for: .normal)
    }
    
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
    
    private lazy var gameOverButton = UIButton().then {
        $0.setTitle("게임 종료", for: .normal)
        $0.tintColor = .white
        $0.backgroundColor = .pointLight
        $0.layer.cornerRadius = 10
    }
    
    private lazy var endLabel = UILabel().then {
        $0.text = "게임 종료"
        $0.textAlignment = .center
        $0.font = .largeTitle
        $0.textColor = .black
    }
    
    private lazy var watchOthersLocationButton: UIButton = UIButton().then {
        $0.setImage(
            .systemEyeCircle?.withTintColor(
                .pointLight,
                renderingMode: .alwaysOriginal
            ), for: .normal
        )
    }
    
    private lazy var pointBoard = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())

    typealias GameDataDatasource = UICollectionViewDiffableDataSource<Section, MultiGamePlayerData>
    typealias GameDataSnapshot = NSDiffableDataSourceSnapshot<Section, MultiGamePlayerData>
    
    private lazy var gameDataSource = makeDataSource()
    private lazy var gameSnapShot = GameDataSnapshot()
    
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
            viewDidAppear: rx.viewDidAppear.asObservable(),
            resetButtonTapped: resetButton.rx.tap.asObservable(),
            watchOthersLocationButtonTapped: watchOthersLocationButton.rx.tap.asObservable(),
            exitButtonTapped: exitButton.rx.tap.asObservable(),
            gameOverButtonTapped: gameOverButton.rx.tap.asObservable()
        )
        let outputs = viewModel.transform(input: inputs)
        outputs.time
            .drive(onNext: { [weak self] time in
                self?.distanceAndTimeBar.timeLabel.text = "\(time)"
            })
            .disposed(by: disposebag)
        
        outputs.gamePoint
            .drive(onNext: { [weak self] point in
                self?.pointLabel.text = "\(point) 점"
            })
            .disposed(by: disposebag)
        
        outputs.movedDistance
            .drive(onNext: { [weak self] distance in
                self?.distanceAndTimeBar.distanceLabel.text = "\(Int(distance)) m"
            })
            .disposed(by: disposebag)
        
        outputs.playerDataFetched
            .drive(onNext: { [weak self] players in
                guard let self = self else {return}
                self.removeAllAnnotations()
                self.mapView.addAnnotations(self.makeAnnotations(data: players))
                self.mapView.addOverlays(self.makeOverlays(data: players))
                self.makeSnapShot(data: players)
                self.pointBoard.reloadData()
            })
            .disposed(by: disposebag)
        
        outputs.currentLocation
            .drive(onNext: { [weak self] currentLocation in
                self?.setCamera(data: currentLocation)
            })
            .disposed(by: disposebag)
        
        outputs.otherLocation
            .drive(onNext: { [weak self] otherLocation in
                self?.setCamera(data: otherLocation)
            })
            .disposed(by: disposebag)
        
        outputs.gameOver
            .drive(onNext: { [weak self] _ in
                self?.configureGameOverUI()
            })
            .disposed(by: disposebag)
    }
    
    private func makeAnnotations(data: [MultiGamePlayerData]) -> [MKAnnotation] {
        let annotations = data.enumerated().map { index, data in
            guard let type = PlayerAnnotation.PlayerType(rawValue: index) else {
                return PlayerAnnotation(player: data, type: .first)
            }
            let playerAnnoation = PlayerAnnotation(player: data, type: type)
            return playerAnnoation
        }
        return annotations
    }
    
    private func makeOverlays(data: [MultiGamePlayerData]) -> [MKOverlay] {
        let nothing = CLLocationCoordinate2D()
        let overlays = data.enumerated().map { index, data in
            guard let type = MKCircle.CircleType(rawValue: index) else {return MKCircle()}
            let circle = PlayerCircle(center: data.currentLocation?.toCLLocationCoordinate2D() ?? nothing, radius: 0.3)
            circle.type = type
            return circle
        }
        return overlays
    }
    
    private func configureGameOverUI() {
        pointLabel.isHidden = true
        exitButton.isHidden = true
        view.addSubview(gameOverButton)
        gameOverButton.snp.makeConstraints {
            $0.bottom.equalTo(distanceAndTimeBar.snp.top).inset(-100)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(60)
            $0.width.equalTo(100)
        }
        view.addSubview(endLabel)
        endLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(80)
            $0.height.equalTo(100)
        }
        
        pointBoard.snp.remakeConstraints {
            $0.top.equalTo(endLabel.snp.bottom).inset(30)
            $0.leading.trailing.equalToSuperview().inset(50)
            $0.bottom.equalTo(gameOverButton.snp.bottom).offset(10)
        }
        
        pointBoard.alpha = 0.8
    }

}

extension MultiGameViewController {
    
    private func layout() {
        addViews()
        addConstraints()
        mapView.delegate = self
        configureCollectionView()
    }
    
    private func addViews() {
        view.addSubview(distanceAndTimeBar)
        view.addSubview(mapView)
        view.addSubview(exitButton)
        view.addSubview(pointLabel)
        view.addSubview(resetButton)
        view.addSubview(watchOthersLocationButton)
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
        
        pointLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(80)
            $0.top.equalToSuperview().inset(60)
            $0.height.equalTo(80)
        }
        
        resetButton.snp.makeConstraints {
            $0.bottom.equalTo(distanceAndTimeBar.snp.top).inset(-10)
            $0.trailing.equalToSuperview().inset(10)
            $0.width.height.equalTo(60)
        }
        
        watchOthersLocationButton.snp.makeConstraints {
            $0.bottom.equalTo(resetButton.snp.top).inset(-10)
            $0.trailing.equalTo(resetButton)
            $0.width.height.equalTo(resetButton)
        }
    }
    
    private func removeAllAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
    }
    
}

extension MultiGameViewController: MKMapViewDelegate {
    func mapView(
        _ mapView: MKMapView,
        rendererFor overlay: MKOverlay
    ) -> MKOverlayRenderer {
        guard let circleOverLay = overlay as? PlayerCircle else {
            return MKOverlayRenderer()
        }
        let circleRenderer = MKCircleRenderer(circle: circleOverLay)
        circleRenderer.strokeColor = circleOverLay.overlayColor()
        circleRenderer.fillColor = circleOverLay.overlayColor()
        circleRenderer.alpha = 0.5
        return circleRenderer
    }
    
    func mapView(
        _ mapView: MKMapView,
        viewFor annotation: MKAnnotation
    ) -> MKAnnotationView? {
        let annotationView = PlayerAnnotationView(
            annotation: annotation,
            reuseIdentifier: PlayerAnnotationView.identifier
        )
        annotationView.canShowCallout = true
        return annotationView
    }

}

extension MultiGameViewController {
    private func makeDataSource() -> GameDataDatasource {
        let dataSource = GameDataDatasource(collectionView: pointBoard) { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: GameRankCollectionViewCell.identifier,
                for: indexPath
            ) as? GameRankCollectionViewCell else {return UICollectionViewCell()}
            cell.bind(data: itemIdentifier, rank: indexPath.row+1)
            return cell
        }
        return dataSource
    }
    
    private func makeSnapShot(data: [MultiGamePlayerData]) {
        let oldItems = gameSnapShot.itemIdentifiers(inSection: .ranking)
        gameSnapShot.deleteItems(oldItems)
        let data = sortData(data: data)
        gameSnapShot.appendItems(data, toSection: .ranking)
        gameDataSource.apply(gameSnapShot, animatingDifferences: true)
    }
    
    private func sortData(data: [MultiGamePlayerData]) -> [MultiGamePlayerData] {
        return data.sorted { player1, player2 in
            return player1.point > player2.point
        }
    }
    
    private func registerCollectionView() {
        pointBoard.register(
            GameRankCollectionViewCell.self,
            forCellWithReuseIdentifier: GameRankCollectionViewCell.identifier
        )
    }
    
    private func configureCollectionView() {
        pointBoard = UICollectionView(frame: .zero, collectionViewLayout: makeCompositonLayout())
        view.addSubview(pointBoard)
        registerCollectionView()
        pointBoard.backgroundColor = .gameRoomColor
        pointBoard.alpha = 0.5
        pointBoard.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(10)
            $0.top.equalTo(exitButton.snp.bottom).inset(-10)
            $0.height.equalTo(200)
            $0.width.equalTo(170)
        }
        gameSnapShot.appendSections([.ranking])
    }
    
    private func makeCompositonLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(50)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(50)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension MultiGameViewController {
    private func setCamera(data: Coordinate) {
        let initialLocation = CLLocation(latitude: data.latitude, longitude: data.longitude)
        let region = MKCoordinateRegion(
            center: initialLocation.coordinate,
            latitudinalMeters: 150,
            longitudinalMeters: 150
        )
        mapView.setCenter(initialLocation.coordinate, animated: true)
        mapView.setRegion(region, animated: true)
    }
}
