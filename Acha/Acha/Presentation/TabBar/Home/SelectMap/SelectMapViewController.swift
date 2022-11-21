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
    
    private lazy var mapNameLabel = PaddingLabel(topInset: 0,
                                                 bottomInset: 0,
                                                 leftInset: 20,
                                                 rightInset: 20)
        .then {
            $0.layer.backgroundColor = UIColor.pointLight.cgColor
            $0.font = .boldBody
            $0.textColor = .white
            $0.text = "땅 이름 랭킹"
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 15
            
            // 왼쪽 위, 오른쪽 위 테두리
            let cornerMask: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            $0.layer.maskedCorners = cornerMask
        }
    
    lazy var rankingCollectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: configureCollectionViewLayout()).then {
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 15
        }
    
    // MARK: - Properties
    private let viewModel: SelectMapViewModel
    private var disposeBag = DisposeBag()
    
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
        
        view.addSubview(rankingView)
        rankingView.snp.makeConstraints {
            $0.bottom.equalTo(startButton.snp.top).offset(-30)
            $0.leading.trailing.equalTo(mapView).inset(20)
            $0.height.equalTo(300)
        }
        
        rankingView.addSubview(mapNameLabel)
        mapNameLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }
        
        rankingView.addSubview(rankingCollectionView)
        rankingCollectionView.snp.makeConstraints {
            $0.top.equalTo(mapNameLabel.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-15)
        }
        
    }
    
    private func bind() {
        
        let input = SelectMapViewModel.Input(startButtonTapped: startButton.rx.tap.asObservable(),
                                             backButtonTapped: backButton.rx.tap.asObservable())
        let output = viewModel.transform(input: input)
        
        output.mapCoordinates
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] maps in
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
        if annotation is MKUserLocation { return }
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
        viewModel.selectedMap = annotation.map
        
        guard let rankings = viewModel.rankings[annotation.map.mapID] else { return }
        makeSnapshot(rankings: rankings)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect annotation: MKAnnotation) {
        rankingView.isHidden = true
        startButton.isValid = false
        
        guard let annotation = annotation as? MapAnnotation else { return }
        let renderer = mapView.renderer(for: annotation.polyLine) as? MKPolylineRenderer
        renderer?.strokeColor = .gray
    }
}

// MARK: - UICollectionViewDelegate
extension SelectMapViewController: UICollectionViewDelegate {
    
    private func configureCollectionView() {
        rankingCollectionView.contentInsetAdjustmentBehavior = .never
        rankingCollectionView.delegate = self
        
        rankingCollectionView.register(SelectMapRecordCell.self,
                                       forCellWithReuseIdentifier: SelectMapRecordCell.identifier)
        configureCollectionViewDataSource()
    }
    
    private func configureCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (_, _ ) -> NSCollectionLayoutSection? in
            let itemsize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(70))
            let groupInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            
            return self.makeSectionLayout(itemSize: itemsize,
                                          groupSize: groupSize,
                                          groupInsets: groupInsets)
        }
        
        return layout
    }
    
    private func configureCollectionViewDataSource() {
        dataSource = DataSource(collectionView: rankingCollectionView,
                                cellProvider: { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectMapRecordCell.identifier,
                                                                for: indexPath) as? SelectMapRecordCell
            else { return UICollectionViewCell() }
            cell.bind(ranking: indexPath.row + 1, record: itemIdentifier)
            return cell
        })
    }
    
    private func makeSectionLayout(itemSize: NSCollectionLayoutSize,
                                   groupSize: NSCollectionLayoutSize,
                                   groupInsets: NSDirectionalEdgeInsets? = nil,
                                   sectionInsets: NSDirectionalEdgeInsets? = nil,
                                   headerSize: NSCollectionLayoutSize? = nil,
                                   orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior? = nil) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        
        if let groupInsets { group.contentInsets = groupInsets }
        
        let section = NSCollectionLayoutSection(group: group)
        if let sectionInsets { section.contentInsets = sectionInsets }
        
        if let headerSize {
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            section.boundarySupplementaryItems = [sectionHeader]
        }
    
        if let orthogonalScrollingBehavior {
            section.orthogonalScrollingBehavior = orthogonalScrollingBehavior
        }
        
        return section
    }
    
    private func makeSnapshot(rankings: [Record]) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections(["Ranking"])
        snapshot.appendItems(rankings, toSection: "Ranking")
        dataSource.apply(snapshot)
    }
}
