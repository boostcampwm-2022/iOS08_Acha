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

enum RecordViewSections: Hashable {
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

enum RecordViewItems: Hashable {
    case chart([RecordViewChartData])
    case myRecord(RecordViewRecord)
}

class RecordViewController: UIViewController, UICollectionViewDelegate {
    // MARK: - UI properties
    private var collectionView: UICollectionView!
    
    // MARK: - Properties
    typealias DataSource = UICollectionViewDiffableDataSource<RecordViewSections, RecordViewItems>
    private var dataSource: DataSource!
    private let viewModel: RecordViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycles
    init(viewModel: RecordViewModel) {
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
        let input = RecordViewModel.Input(
            viewDidLoadEvent: rx.methodInvoked(#selector(viewDidAppear(_:)))
                .map({ _ in })
                .asObservable()
        )
        
        let output = self.viewModel.transform(input: input)
        
        output.sectionDays.asDriver(onErrorJustReturn: [:])
            .drive(onNext: { [weak self] sectionDays in
                guard let self else { return }
                self.viewModel.sectionDays = sectionDays
            }).disposed(by: disposeBag)
        
        output.days.asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] days in
                guard let self else { return }
                self.appendSections(days: days)
            }).disposed(by: disposeBag)
        
        output.weekDistances.asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] weekDistances in
                guard let self else { return }
                self.appendChartItem(weekDistances: weekDistances)
            }).disposed(by: disposeBag)
        
        output.recordAtDays.asDriver(onErrorJustReturn: [:])
            .drive(onNext: { [weak self] recordAtDays in
                guard let self else { return }
                self.appendRecordItem(recordAtDays: recordAtDays)
            }).disposed(by: disposeBag)
        
        output.mapData.asDriver(onErrorJustReturn: [:])
            .drive(onNext: { [weak self] mapData in
                guard let self else { return }
                self.viewModel.mapData = mapData
            }).disposed(by: disposeBag)
    }
    
    private func configureUI() {
        navigationItem.title = "개인 기록"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.pointLight]
        view.backgroundColor = .white
        
        configureCollectionView()
    }

    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
        collectionView.delegate = self
        collectionView.contentInsetAdjustmentBehavior = .never
        
        collectionView.register(RecordHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: RecordHeaderView.identifier)
        collectionView.register(RecordChartCell.self, forCellWithReuseIdentifier: RecordChartCell.identifier)
        collectionView.register(RecordCell.self, forCellWithReuseIdentifier: RecordCell.identifier)
        
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
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecordChartCell.identifier,
                                                                    for: indexPath) as? RecordChartCell else {
                    return UICollectionViewCell()
                }
                
                cell.bind(recordViewChartDataArray: recordViewChartDataArray)
                
                return cell
            case .myRecord(let recordViewRecord):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecordCell.identifier,
                                                                    for: indexPath) as? RecordCell else {
                    return UICollectionViewCell()
                }
                
                let mapName = self.viewModel.searchMapName(mapId: recordViewRecord.mapID)
                cell.bind(mapName: mapName, recordViewRecord: recordViewRecord)
                
                return cell
            }
        })
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: RecordHeaderView.identifier,
                    for: indexPath) as? RecordHeaderView
                else { return UICollectionReusableView() }
                
                let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
                guard let dayTotalRecord = self.viewModel.sectionDays[section.title]
                else { return UICollectionReusableView() }
                
                let headerRecord = RecordViewHeaderRecord(date: section.title,
                                                          distance: dayTotalRecord.distance,
                                                kcal: dayTotalRecord.calorie)
                header.bind(headerRecord: headerRecord)
                
                return header
            }
            return UICollectionReusableView()
        }
    }
    
    private func configureCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, _ ) -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case 0:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .absolute(413))
                let groupInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                let sectionInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                
                return self.makeSectionLayout(itemSize: itemSize,
                                              groupSize: groupSize,
                                              groupInsets: groupInsets,
                                              sectionInsets: sectionInsets)
            default:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .absolute(110))
                let groupInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10)
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .absolute(100))
                let sectionInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 20, trailing: 0)
                return self.makeSectionLayout(itemSize: itemSize,
                                              groupSize: groupSize,
                                              groupInsets: groupInsets,
                                              sectionInsets: sectionInsets,
                                              headerSize: headerSize)
            }
        }
        return layout
    }

    private func makeSectionLayout(
        itemSize: NSCollectionLayoutSize,
        groupSize: NSCollectionLayoutSize,
        groupInsets: NSDirectionalEdgeInsets? = nil,
        sectionInsets: NSDirectionalEdgeInsets? = nil,
        headerSize: NSCollectionLayoutSize? = nil,
        orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior? = nil
    ) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
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
    
    private func appendSections(days: [String]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendSections([.chart])
        days.forEach { day in
            snapshot.appendSections([.record(day)])
        }
        dataSource.apply(snapshot)
    }
    
    private func appendChartItem(weekDistances: [RecordViewChartData]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems([.chart(weekDistances)], toSection: .chart)
        dataSource.apply(snapshot)
    }
    
    private func appendRecordItem(recordAtDays: [String: [RecordViewRecord]]) {
        var snapshot = dataSource.snapshot()
        recordAtDays.forEach { date, records in
            records.forEach { record in
                snapshot.appendItems([.myRecord(record)], toSection: .record(date))
            }
        }
        dataSource.apply(snapshot)
    }
}
