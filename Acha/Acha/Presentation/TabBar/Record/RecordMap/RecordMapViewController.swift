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
    var sectionHeaderView = RecordMapHeaderView()
    
    // MARK: - Properties
    typealias DataSource = UICollectionViewDiffableDataSource<RecordMapViewSections, RecordMapViewItems>
    private var dataSource: DataSource!
    private let viewModel: RecordMapViewModel
    private let disposeBag = DisposeBag()
    var sectionHeaderCreateEvent = PublishRelay<String>()
    var categoryCellTapEvent = PublishRelay<String>()
    var dropDownMenuTapEvent = PublishRelay<String>()
    
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
        configureUI()
        bind()
    }
    
    // MARK: - Helpers
    private func bind() {
        let input = RecordMapViewModel.Input(
            viewDidLoadEvent: rx.methodInvoked(#selector(viewDidAppear(_:)))
                .map({ _ in})
                .asObservable(),
            sectionHeaderCreateEvent: self.sectionHeaderCreateEvent.asObservable(),
            dropDownMenuTapEvent: self.dropDownMenuTapEvent.asObservable(),
            categoryCellTapEvent: self.categoryCellTapEvent.asObservable()
        )
        
        let output = self.viewModel.transform(input: input)
        
        output.dropDownMenus.asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] maps in
                guard let self else { return }
                self.sectionHeaderView.setDropDownMenus(maps: maps)
            }).disposed(by: disposeBag)
        
        output.mapNameAndRecords.asDriver(onErrorJustReturn: ("", []))
            .drive(onNext: { [weak self] mapNameAndRecords in
                guard let self else {return }
                self.updateRankingSectionAndItems(mapName: mapNameAndRecords.0,
                                                  records: mapNameAndRecords.1)
            }).disposed(by: disposeBag)
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
                return self.categoryLayout()
            case 1:
                return self.rankingLayout()
            default:
                return self.mapViewLayout()
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
                
                let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
                
                header.setMapName(mapName: section.title)
                self.sectionHeaderView = header
                self.sectionHeaderCreateEvent.accept(section.title)
                header.dropDownMenuTapEvent
                    .subscribe {
                        self.dropDownMenuTapEvent.accept($0)
                    }.disposed(by: self.disposeBag)
                
                return header
            }
            return UICollectionReusableView()
        }
    }
    
    private func categoryLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let itemInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 15)
        item.contentInsets = itemInsets
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(50))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                     subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let sectionInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
        section.contentInsets = sectionInsets
        section.orthogonalScrollingBehavior = .continuous
        
        return section
    }
    
    private func rankingLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(70))
        let groupInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                     subitems: [item])
        group.contentInsets = groupInsets
        
        let section = NSCollectionLayoutSection(group: group)
        let sectionInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
        section.contentInsets = sectionInsets
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(100))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader, alignment: .top
        )
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    private func mapViewLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(70))
        let groupInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                     subitems: [item])
        group.contentInsets = groupInsets
        
        let sectionInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 20, trailing: 0)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = sectionInsets
        
        return section
    }
    
    func updateRankingSectionAndItems(mapName: String, records: [RecordViewRecord]) {
        var snapshot = dataSource.snapshot()
        let previousSections = snapshot.sectionIdentifiers.filter { $0 != .category }
        snapshot.deleteSections(previousSections)
        
        snapshot.appendSections([.ranking(mapName)])
        records.prefix(3).enumerated().forEach {
            snapshot.appendItems([.ranking($0.offset + 1, $0.element)], toSection: .ranking(mapName))
        }
        
        dataSource.apply(snapshot)
    }
    
    func makeSnapshot() {
        var snapshot = dataSource.snapshot()
        snapshot.appendSections([.category])
        Locations.allCases.forEach {
            snapshot.appendItems([.category($0.string)], toSection: .category)
        }
        dataSource.apply(snapshot)
    }
}

extension RecordMapViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell  = collectionView.cellForItem(at: indexPath) as? RecordMapCategoryCell else { return }
        self.categoryCellTapEvent.accept(cell.getLocationName())
    }
}
