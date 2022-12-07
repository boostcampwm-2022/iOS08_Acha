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
            resetButtonTapped: resetButton.rx.tap.asObservable()
        )
        let outputs = viewModel.transform(input: inputs)
        outputs.time
            .drive(onNext: { [weak self] time in
                self?.distanceAndTimeBar.timeLabel.text = "\(time)"
            })
            .disposed(by: disposebag)
        
        outputs.visitedLocation
            .drive(onNext: { [weak self]  location in
//                self?.mapView.addOverlay(MKCircle(center: location.toCLLocationCoordinate2D(), radius: 0.1))
//                let annotation = PlayerAnnotation(player: MultiGamePlayerData(
//                    id: "aewtew",
//                    nickName: "AWettwe", currentLocation: location,
//                    point: 30)
//                )
//                self?.removeAllAnnotations()
//                self?.mapView.addAnnotation(annotation)
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
                print(currentLocation)
                self?.setCamera(data: currentLocation)
            })
            .disposed(by: disposebag)
    }
    
    private func makeAnnotations(data: [MultiGamePlayerData]) -> [MKAnnotation] {
        return data.map { PlayerAnnotation(player: $0) }
    }
    
    private func makeOverlays(data: [MultiGamePlayerData]) -> [MKOverlay] {
        let nothing = CLLocationCoordinate2D()
        let annotations = data.enumerated().map { index, data in
            let circle = MKCircle(center: data.currentLocation?.toCLLocationCoordinate2D() ?? nothing, radius: 0.2)
            guard let type = MKCircle.CircleType(rawValue: index) else {return MKCircle()}
            circle.type = type
            return circle
        }
        return annotations
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
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(80)
            $0.height.equalTo(80)
        }
        
        resetButton.snp.makeConstraints {
            $0.bottom.equalTo(distanceAndTimeBar.snp.top).inset(-10)
            $0.trailing.equalToSuperview().inset(10)
            $0.width.height.equalTo(60)
        }
    }
    
}

extension MultiGameViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circleOverLay = overlay as? MKCircle else {return MKOverlayRenderer()}
        
        let circleRenderer = MKCircleRenderer(circle: circleOverLay)
        circleRenderer.strokeColor = circleOverLay.overLayColor
        circleRenderer.fillColor = circleOverLay.overLayColor
        circleRenderer.alpha = 0.5
        return circleRenderer
    }
    
    private func removeAllAnnotations() {
//        let annotations = mapView.annotations.filter {
//            $0 !== mapView.userLocation
//        }
        mapView.removeAnnotations(mapView.annotations)
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
        gameSnapShot.appendItems(data, toSection: .ranking)
        gameDataSource.apply(gameSnapShot, animatingDifferences: true)
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
            $0.width.equalTo(180)
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
