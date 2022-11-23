//
//  RecordMapViewController.swift
//  Acha
//
//  Created by 배남석 on 2022/11/22.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

enum RecordMapViewSections: Hashable {
    case category
    case ranking(String)
    
    var title: String {
        switch self {
        case .category:
            return "category"
        case .ranking(let mapName):
            return mapName
        }
    }
}

enum RecordMapViewItems: Hashable {
    case category(String)
    case ranking(Int, RecordViewRecord)
}

class RecordMapViewController: UIViewController {
    // MARK: - UI properties
    private var collectionView: UICollectionView!
    
    // MARK: - Properties
    typealias DataSource = UICollectionViewDiffableDataSource<RecordMapViewSections, RecordMapViewItems>
    private var dataSource: DataSource!
    private let viewModel: RecordMapViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycles
    init(viewModel: RecordMapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        configureUI()
        bind()
    }
    
    // MARK: - Helpers
    
    private func bind() {
        let input = RecordMapViewModel.Input(
            viewDidLoadEvent: rx.methodInvoked(#selector(viewDidAppear(_:)))
                .map({_ in})
                .asObservable()
        )
        
        let output = self.viewModel.transform(input: input)
        
        output.recordData.asDriver(onErrorJustReturn: [:])
            .drive(onNext: { [weak self] recordData in
                guard let self else { return }
                self.viewModel.recordData = recordData
            }).disposed(by: disposeBag)
        
        output.mapDataAtMapName.asDriver(onErrorJustReturn: [:])
            .drive(onNext: { [weak self] mapDataAtMapName in
                guard let self else { return }
                self.viewModel.mapDataAtMapName = mapDataAtMapName
            }).disposed(by: disposeBag)
        
        output.mapDataAtCategory.asDriver(onErrorJustReturn: [:])
            .drive(onNext: { [weak self] mapDataAtCategory in
                guard let self else { return }
                self.viewModel.mapDataAtCategory = mapDataAtCategory
                self.appendRankingSectionAndItems()
            }).disposed(by: disposeBag)
    }
    
    private func setUpViews() {
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        
        configureCollectionView()
        makeSnapshot()
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.delegate = self
        
        collectionView.register(RecordMapCategoryCell.self,
                                forCellWithReuseIdentifier: RecordMapCategoryCell.identifier)
        collectionView.register(RecordMapRankingCell.self,
                                forCellWithReuseIdentifier: RecordMapRankingCell.identifier)
        collectionView.register(RecordMapHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: RecordMapHeaderView.identifier)
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.top.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(15)
        }
        
        configureCollectionViewDataSource()
    }
    
    private func configureCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, _ ) -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case 0:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25),
                                                      heightDimension: .fractionalHeight(1.0))
                let itemInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 15)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .absolute(50))
                let sectionInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                let orthogonalScrollingBehavior = UICollectionLayoutSectionOrthogonalScrollingBehavior.continuous
                
                return self.makeSectionLayout(itemSize: itemSize,
                                              itemInsets: itemInsets,
                                              groupSize: groupSize,
                                              sectionInsets: sectionInsets,
                                              orthogonalScrollingBehavior: orthogonalScrollingBehavior)
            case 1:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .absolute(70))
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .absolute(100))
                let groupInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)
                let sectionInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                return self.makeSectionLayout(itemSize: itemSize,
                                              groupSize: groupSize,
                                              groupInsets: groupInsets,
                                              sectionInsets: sectionInsets,
                                              headerSize: headerSize)
            default:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .absolute(70))
                let groupInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                let sectionInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 20, trailing: 0)
                return self.makeSectionLayout(itemSize: itemSize,
                                              groupSize: groupSize,
                                              groupInsets: groupInsets,
                                              sectionInsets: sectionInsets)
            }
        }
        return layout
    }
    
    private func configureCollectionViewDataSource() {
        dataSource = DataSource(collectionView: collectionView,
                                cellProvider: { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .category(let locationName):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: RecordMapCategoryCell.identifier,
                    for: indexPath) as? RecordMapCategoryCell else {
                    return UICollectionViewCell()
                }
                
                cell.setLocationName(name: locationName)
                
                return cell
            case .ranking(let rank, let recond):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: RecordMapRankingCell.identifier,
                    for: indexPath) as? RecordMapRankingCell else {
                    return UICollectionViewCell()
                }
                
                cell.bind(ranking: rank, record: recond)
                
                return cell
            }
        })
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: RecordMapHeaderView.identifier,
                    for: indexPath) as? RecordMapHeaderView
                else { return UICollectionReusableView() }
                
                header.parentViewController = self
                
                let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
        
                guard let map = self.viewModel.mapDataAtMapName[section.title],
                      let maps = self.viewModel.mapDataAtCategory[map.location]
                else { return UICollectionReusableView() }
                
                header.setMapName(mapName: section.title)
                header.setDropDownMenus(maps: maps)
                
                return header
            }
            return UICollectionReusableView()
        }
    }
    
    private func makeSectionLayout(
        itemSize: NSCollectionLayoutSize,
        itemInsets: NSDirectionalEdgeInsets? = nil,
        groupSize: NSCollectionLayoutSize,
        groupInsets: NSDirectionalEdgeInsets? = nil,
        sectionInsets: NSDirectionalEdgeInsets? = nil,
        headerSize: NSCollectionLayoutSize? = nil,
        orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior? = nil
    ) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        if let itemInsets {
            item.contentInsets = itemInsets
        }
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        if let groupInsets {
            group.contentInsets = groupInsets
        }
        
        let section = NSCollectionLayoutSection(group: group)
        if let headerSize {
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            
            section.boundarySupplementaryItems = [sectionHeader]
        }
        if let sectionInsets {
            section.contentInsets = sectionInsets
        }
        if let orthogonalScrollingBehavior {
            section.orthogonalScrollingBehavior = orthogonalScrollingBehavior
        }
        return section
    }
    
    func appendRankingSectionAndItems(categoryName: String? = "인천") {
        guard let categoryName,
              let maps = self.viewModel.mapDataAtCategory[categoryName] else { return }
        
        let map = maps[0]
        var snapshot = dataSource.snapshot()
        snapshot.appendSections([.ranking(map.name)])
        
        guard let records = map.records else {
            dataSource.apply(snapshot)
            return
        }
        
        for index in 1...3 {
            guard let record = self.viewModel.recordData[records[index-1]] else {
                dataSource.apply(snapshot)
                return
            }
            snapshot.appendItems([.ranking(index, record)], toSection: .ranking(map.name))
        }
        dataSource.apply(snapshot)
    }
    
    func appendRankingSectionAndItems(mapName: String) {
        var snapshot = dataSource.snapshot()
        guard let map = self.viewModel.mapDataAtMapName[mapName] else { return }
        snapshot.appendSections([.ranking(mapName)])
        
        guard let records = map.records else {
            dataSource.apply(snapshot)
            return
        }
        for index in 1...3 {
            guard let record = self.viewModel.recordData[records[index-1]] else {
                dataSource.apply(snapshot)
                return
            }
            snapshot.appendItems([.ranking(index, record)], toSection: .ranking(mapName))
        }
        dataSource.apply(snapshot)
    }
    
    func makeSnapshot() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.deleteSections(snapshot.sectionIdentifiers)
        snapshot.appendSections([.category])
        ["서울", "인천", "경기", "강원", "대구", "부평"].forEach {
            snapshot.appendItems([.category($0)], toSection: .category)
        }
        dataSource.apply(snapshot)
    }
}

extension RecordMapViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell  = collectionView.cellForItem(at: indexPath) as? RecordMapCategoryCell else { return }
        makeSnapshot()
        appendRankingSectionAndItems(categoryName: cell.getLocationName())
    }
}
