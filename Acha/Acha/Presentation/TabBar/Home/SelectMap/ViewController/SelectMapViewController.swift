//  SelectMapViewController.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/14.
//

import UIKit
import MapKit
import Then
import SnapKit
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
    
    private lazy var backButton: UIButton = UIButton().then {
        $0.setImage(SystemImageNameSpace.xmark.uiImage, for: .normal)
        $0.tintColor = .pointLight
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 30)
        $0.setPreferredSymbolConfiguration(imageConfig, forImageIn: .normal)
    }
    
    private lazy var rankingCollectionView: UICollectionView = UICollectionView(
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
    private let regionDidChanged = PublishSubject<MapRegion>()
    private let mapSelectedEvent = PublishSubject<Map>()
    
    typealias DataSource = UICollectionViewDiffableDataSource<String, Record>
    private var dataSource: DataSource?
    
    // MARK: - Lifecycles
    init(viewModel: SelectMapViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bind()
        configureMapViewDelegate()
        configureCollectionView()
    }
    
    override func setUpMapView() {
        super.setUpMapView()
        mapView?.isRotateEnabled = false
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
        
        guard let mapView else { return }
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
            mapSelected: mapSelectedEvent,
            regionDidChanged: regionDidChanged,
            startButtonTapped: startButton.rx.tap.asObservable(),
            backButtonTapped: backButton.rx.tap.asObservable())
        let output = viewModel.transform(input: input)

        output.visibleMaps
            .subscribe { [weak self] maps in
                maps.forEach { mapElement in
                    self?.displayMap(mapElement)
                }
            }.disposed(by: disposeBag)
        
        output.selectedMapRankings
            .subscribe { [weak self] mapName, records in
                self?.makeSnapshot(rankings: records, mapName: mapName)
            }
            .disposed(by: disposeBag)
        
        output.cannotStart
            .subscribe { [weak self] _ in
                self?.showAlert(title: "선택한 땅과의 거리가 너무 멀어요",
                                message: "가까이 가서 다시 시작해주세요")
            }.disposed(by: disposeBag)
    }
    
    private func configureMapViewDelegate() {
        guard let mapView else { return }
        mapView.rx.regionDidChange
            .subscribe(onNext: { [weak self] region in
                guard let self else { return }
                let center = Coordinate(latitude: region.center.latitude,
                                        longitude: region.center.longitude)
                let span = CoordinateSpan(latitudeDelta: region.span.latitudeDelta,
                                          longitudeDelta: region.span.longitudeDelta)
                let mapRegion = MapRegion(center: center, span: span)
                self.regionDidChanged.onNext(mapRegion)
            }).disposed(by: disposeBag)
        
        mapView.rx.didSelectAnnotation
            .subscribe(onNext: { [weak self] annotation in
                if annotation is MKUserLocation { return }
                
                guard let self,
                      let annotation = annotation as? MapAnnotation else { return }
                self.rankingCollectionView.isHidden = false
                self.startButton.isValid = true
                self.changeLineColor(polyLine: annotation.polyLine, color: .red)
                
                // 땅이 랭킹뷰 위쪽에 오도록 지도 포커스
                let center = CLLocationCoordinate2D(latitude: annotation.map.centerCoordinate.latitude - 0.003,
                                                    longitude: annotation.map.centerCoordinate.longitude)
                self.focusMapLocation(center: center)
                
                self.mapSelectedEvent.onNext(annotation.map)
            }).disposed(by: disposeBag)
        
        mapView.rx.didDeselectAnnotation
            .subscribe(onNext: { [weak self] annotation in
                guard let self,
                      let annotation = annotation as? MapAnnotation else { return }
                self.rankingCollectionView.isHidden = true
                self.startButton.isValid = false
                self.changeLineColor(polyLine: annotation.polyLine, color: .gray)
            }).disposed(by: disposeBag)
    }
    
    private func displayMap(_ map: Map) {
        let coordinates = map.coordinates.map {
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        }
        // 테두리 선
        let lineDraw = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView?.addOverlay(lineDraw)
        // pin
        let annotation = MapAnnotation(map: map, polyLine: lineDraw)
        mapView?.addAnnotation(annotation)
    }
    
    private func changeLineColor(polyLine: MKPolyline, color: UIColor) {
        if let renderer = mapView?.renderer(for: polyLine) as? MKPolylineRenderer {
            renderer.strokeColor = color
        }
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
        dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader,
                  let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: SelectMapRankingHeaderView.identifier,
                    for: indexPath) as? SelectMapRankingHeaderView
            else { return UICollectionReusableView() }
            
            guard let dataSource = self?.dataSource,
                  let mapView = self?.mapView else { return header }
            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            header.setData(mapName: section, closeButtonHandler: {
                mapView.deselectAnnotation(mapView.selectedAnnotations.first, animated: true)
            })
            return header
        }
    }
    
    private func makeSnapshot(rankings: [Record], mapName: String) {
        guard let dataSource else { return }
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([mapName])
        snapshot.appendItems(rankings, toSection: mapName)
        dataSource.apply(snapshot)
    }
}
