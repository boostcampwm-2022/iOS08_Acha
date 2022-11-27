//
//  RecordViewController.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxRelay
import RxCocoa

class RecordMainViewController: UIViewController, UICollectionViewDelegate {
    enum RecordMainViewSections: Hashable {
        case chart
        case record(String)
        
        var title: String {
            switch self {
            case .chart:
                return "chart"
            case .record(let title):
                return title
            }
        }
    }

    enum RecordMainViewItems: Hashable {
        case chart([RecordViewChartData])
        case myRecord(RecordViewRecord)
    }
    
    // MARK: - UI properties
    private var collectionView: UICollectionView!
    var headerView = RecordMainHeaderView()
    var cell = RecordMainCell()
    
    // MARK: - Properties
    typealias DataSource = UICollectionViewDiffableDataSource<RecordMainViewSections, RecordMainViewItems>
    private var dataSource: DataSource!
    private let viewModel: RecordMainViewModel
    private let disposeBag = DisposeBag()
    var headerViewBindEvent = PublishRelay<String>()
    var cellBindEvent = PublishRelay<Int>()
    
    // MARK: - Lifecycles
    init(viewModel: RecordMainViewModel) {
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
        let input = RecordMainViewModel.Input(
                        viewDidAppearEvent: rx.methodInvoked(#selector(viewDidAppear(_:)))
                .map({ _ in })
                .asObservable(),
            headerViewBindEvent: self.headerViewBindEvent.asObservable(),
            cellBindEvent: self.cellBindEvent.asObservable()
        )
        
        let output = self.viewModel.transform(input: input)
        
        output.weekDatas.asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] weekDatas in
                guard let self else { return }
                self.appendChartItem(weekDistances: weekDatas)
            }).disposed(by: disposeBag)
        
        output.allDates.asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] allDays in
                guard let self else { return }
                self.appendSections(dates: allDays)
            }).disposed(by: disposeBag)
        
        output.headerRecord.asDriver(onErrorJustReturn: RecordViewHeaderRecord(date: "",
                                                                               distance: 0,
                                                                               kcal: 0))
            .drive(onNext: { [weak self] headerRecord in
                guard let self else { return }
                self.headerView.bind(headerRecord: headerRecord)
            }).disposed(by: disposeBag)
        
        output.recordsAtDate.asDriver(onErrorJustReturn: [:])
            .drive(onNext: { [weak self] recordsAtDay in
                guard let self else { return }
                self.appendRecordItem(recordsAtDate: recordsAtDay)
            }).disposed(by: disposeBag)
        
        output.mapAtRecordId.asDriver(onErrorJustReturn: Map(mapID: 0,
                                                             name: "",
                                                             centerCoordinate: Coordinate(latitude: 0, longitude: 0),
                                                             coordinates: [], location: "",
                                                             records: nil))
            .drive(onNext: { [weak self] map in
                guard let self else { return }
                self.cell.bind(mapName: map.name)
            }).disposed(by: disposeBag)
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        
        configureCollectionView()
    }

    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
        collectionView.delegate = self
        collectionView.contentInsetAdjustmentBehavior = .never
        
        collectionView.register(RecordMainHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: RecordMainHeaderView.identifier)
        collectionView.register(RecordMainChartCell.self, forCellWithReuseIdentifier: RecordMainChartCell.identifier)
        collectionView.register(RecordMainCell.self, forCellWithReuseIdentifier: RecordMainCell.identifier)
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(15)
        }
        
        configureCollectionViewDataSource()
    }
    
    private func configureCollectionViewDataSource() {
        dataSource = DataSource(collectionView: collectionView,
                                cellProvider: { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .chart(let recordViewChartDataArray):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecordMainChartCell.identifier,
                                                                    for: indexPath) as? RecordMainChartCell else {
                    return UICollectionViewCell()
                }
                
                cell.bind(recordViewChartDataArray: recordViewChartDataArray)
                
                return cell
            case .myRecord(let recordViewRecord):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecordMainCell.identifier,
                                                                    for: indexPath) as? RecordMainCell else {
                    return UICollectionViewCell()
                }
                self.cell = cell
                cell.bindEvent
                    .subscribe(onNext: {
                        self.cellBindEvent.accept($0)
                    }).disposed(by: self.disposeBag)
                cell.bind(mapId: recordViewRecord.mapID, recordViewRecord: recordViewRecord)
                
                return cell
            }
        })
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: RecordMainHeaderView.identifier,
                    for: indexPath) as? RecordMainHeaderView
                else { return UICollectionReusableView() }
                self.headerView = header
                
                header.bindEvent
                    .subscribe(onNext: {
                        self.headerViewBindEvent.accept($0)
                    }).disposed(by: self.disposeBag)
                
                let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
                header.bind(day: section.title)
                
                return header
            }
            return UICollectionReusableView()
        }
    }
    
    private func configureCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, _ ) -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case 0:
                return self.chartLayout()
            default:
                return self.recordLayout()
            }
        }
        return layout
    }
    
    private func chartLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(413))
        let groupInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        group.contentInsets = groupInsets
        let sectionInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = sectionInsets
        
        return section
    }
    
    private func recordLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(110))
        let groupInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        group.contentInsets = groupInsets
        let section = NSCollectionLayoutSection(group: group)
        let sectionInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 20, trailing: 0)
        section.contentInsets = sectionInsets
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(100))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    private func appendSections(dates: [String]) {
        var snapshot = dataSource.snapshot()
        let previousSections = snapshot.sectionIdentifiers.filter { $0 != .chart }
        snapshot.deleteSections(previousSections)
        
        dates.forEach { dates in
            snapshot.appendSections([.record(dates)])
        }
        dataSource.apply(snapshot)
    }
    
    private func appendChartItem(weekDistances: [RecordViewChartData]) {
        var snapshot = dataSource.snapshot()
        let previousSections = snapshot.sectionIdentifiers.filter { $0 == .chart }
        snapshot.deleteSections(previousSections)
        
        snapshot.appendSections([.chart])
        snapshot.appendItems([.chart(weekDistances)], toSection: .chart)
        dataSource.apply(snapshot)
    }
    
    private func appendRecordItem(recordsAtDate: [String: [RecordViewRecord]]) {
        var snapshot = dataSource.snapshot()
        recordsAtDate.forEach {
            let date = $0.key
            $0.value.forEach {
                snapshot.appendItems([.myRecord($0)], toSection: .record(date))
            }
        }
        dataSource.apply(snapshot)
    }
}
