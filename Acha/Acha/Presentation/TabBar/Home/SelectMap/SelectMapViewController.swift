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
import RxCocoa

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
    
    private lazy var backButton: UIButton = UIButton().then {
        $0.setImage(SystemImageNameSpace.xmark.uiImage, for: .normal)
        $0.tintColor = .pointLight
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 30)
        $0.setPreferredSymbolConfiguration(imageConfig, forImageIn: .normal)
    }
    
    private lazy var rankingView = UIView().then {
        $0.layer.shadowOffset = CGSize(width: 0, height: 10)
        $0.layer.shadowColor = UIColor.gray.cgColor
        $0.layer.shadowOpacity = 1.0
        $0.layer.shadowOffset = CGSize.zero
        $0.layer.shadowRadius = 6
        $0.layer.cornerRadius = 15
        $0.backgroundColor = .white
        $0.isHidden = true
    }
    
    lazy var rankingCollectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: configureCollectionViewLayout())
        .then {
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 15
            $0.isScrollEnabled = false
            $0.isHidden = true
        }
    
    // MARK: - Properties
    private let viewModel: SelectMapViewModel
    private var disposeBag = DisposeBag()
    private let regionDidChanged = PublishSubject<MapRegion>()
    
    typealias DataSource = UICollectionViewDiffableDataSource<String, Record>
    private var dataSource: DataSource!
    
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
        bind()
        configureCollectionView()
    }
    
    override func setUpMapView() {
        super.setUpMapView()
        mapView.isRotateEnabled = false
    }
}

extension SelectMapViewController {
    
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
        
        view.addSubview(backButton)
        backButton.snp.makeConstraints {
            $0.top.equalTo(focusButton)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(15)
            $0.width.height.equalTo(40)
        }
        
        view.addSubview(rankingCollectionView)
        rankingCollectionView.snp.makeConstraints {
            $0.bottom.equalTo(startButton.snp.top).offset(-30)
            $0.leading.trailing.equalTo(mapView).inset(20)
            $0.height.equalTo(290)
        }
    }
    
    private func bind() {
        let input = SelectMapViewModel.Input(
            viewWillAppearEvent: rx.methodInvoked(#selector(UIViewController.viewWillAppear)).map { _ in },
            regionDidChanged: regionDidChanged,
            startButtonTapped: startButton.rx.tap.asObservable(),
            backButtonTapped: backButton.rx.tap.asObservable())
        let output = viewModel.transform(input: input)

        output.visibleMap
            .subscribe { [weak self] mapElement in
                let coordinates = mapElement.coordinates.map {
                    CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
                }
                
                // 테두리 선
                let lineDraw = MKPolyline(coordinates: coordinates, count: coordinates.count)
                self?.mapView.addOverlay(lineDraw)
                
                // pin
                let annotation = MapAnnotation(map: mapElement, polyLine: lineDraw)
                self?.mapView.addAnnotation(annotation)
            }.disposed(by: disposeBag)
        
        output.cannotStart
            .subscribe { [weak self] _ in
                #warning("showAlert으로 변경")
                let alert = UIAlertController(title: "선택한 땅과의 거리가 너무 멀어요",
                                  message: "가까이 가서 다시 시작해주세요",
                                  preferredStyle: .alert)
                let okAction = UIAlertAction(title: "확인", style: .default)
                alert.addAction(okAction)
                self?.present(alert, animated: true)
            }.disposed(by: disposeBag)
    }
}

// MARK: - MKMapViewDelegate
extension SelectMapViewController {
    
    /// annotation (=pin) 클릭 시 액션
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        if annotation is MKUserLocation { return }
        rankingCollectionView.isHidden = false
        startButton.isValid = true
        
        // 테두리 색상 변경
        guard let annotation = annotation as? MapAnnotation else { return }
        if let renderer = mapView.renderer(for: annotation.polyLine) as? MKPolylineRenderer {
            renderer.strokeColor = .red
        }
        
        // 땅이 랭킹뷰 위쪽에 오도록 지도 포커스
        let center = CLLocationCoordinate2D(latitude: annotation.map.centerCoordinate.latitude - 0.003,
                                            longitude: annotation.map.centerCoordinate.longitude)
        focusMapLocation(center: center)
        viewModel.selectedMap = annotation.map
        let name = annotation.map.name
        
        guard let rankings = viewModel.rankings[annotation.map.mapID] else { return }
        makeSnapshot(rankings: rankings, mapName: name)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect annotation: MKAnnotation) {
        rankingCollectionView.isHidden = true
        startButton.isValid = false
        
        guard let annotation = annotation as? MapAnnotation else { return }
        let renderer = mapView.renderer(for: annotation.polyLine) as? MKPolylineRenderer
        renderer?.strokeColor = .gray
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = Coordinate(latitude: mapView.region.center.latitude,
                                longitude: mapView.region.center.longitude)
        let span = CoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta,
                                  longitudeDelta: mapView.region.span.longitudeDelta)
        let region = MapRegion(center: center, span: span)
        regionDidChanged.onNext(region)
    }

}

// MARK: - CLLocationManagerDelegate
extension SelectMapViewController {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else { return }
        viewModel.userLocation = Coordinate(latitude: userLocation.coordinate.latitude,
                                            longitude: userLocation.coordinate.longitude)
    }
}

// MARK: - UICollectionViewDelegate
extension SelectMapViewController {
    
    private func configureCollectionViewLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (_, _) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(75))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                    heightDimension: .absolute(60))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [header]
            return section
        }
    }
    
    private func configureCollectionView() {
        rankingCollectionView.contentInsetAdjustmentBehavior = .never
        rankingCollectionView.register(SelectMapRecordCell.self,
                                       forCellWithReuseIdentifier: SelectMapRecordCell.identifier)
        rankingCollectionView.register(SelectMapRankingHeaderView.self,
                                       forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                       withReuseIdentifier: SelectMapRankingHeaderView.identifier)
        configureCollectionViewDataSource()
    }
    
    private func configureCollectionViewDataSource() {
        dataSource = DataSource(collectionView: rankingCollectionView,
                                cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectMapRecordCell.identifier,
                                                                for: indexPath) as? SelectMapRecordCell
            else { return UICollectionViewCell() }
            cell.bind(ranking: indexPath.row + 1, record: item)
            return cell
        })
        
        configureDataSourceHeader()
    }
    
    private func configureDataSourceHeader() {
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader,
                  let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SelectMapRankingHeaderView.identifier,
                for: indexPath) as? SelectMapRankingHeaderView
            else { return UICollectionReusableView() }
            
            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            header.setData(mapName: section, closeButtonHandler: {
                self.mapView.deselectAnnotation(self.mapView.selectedAnnotations.first, animated: true)
            })
            return header
        }
    }
    
    private func makeSnapshot(rankings: [Record], mapName: String) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([mapName])
        snapshot.appendItems(rankings, toSection: mapName)
        dataSource.apply(snapshot)
    }
}
