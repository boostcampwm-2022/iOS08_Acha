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
        case record(RecordViewHeaderRecord)
        
        var data: RecordViewHeaderRecord {
            switch self {
            case.chart:
                return RecordViewHeaderRecord(date: "", distance: 0, kcal: 0)
            case .record(let data):
                return data
            }
        }
    }

    enum RecordMainViewItems: Hashable {
        case chart([RecordViewChartData])
        case myRecord(Record, String)
    }
    
    // MARK: - UI properties
    private var collectionView: UICollectionView!
    
    // MARK: - Properties
    typealias DataSource = UICollectionViewDiffableDataSource<RecordMainViewSections, RecordMainViewItems>
    private var dataSource: DataSource!
    private let viewModel: RecordMainViewModel
    private let disposeBag = DisposeBag()
    
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
                .asObservable()
        )
        
        let output = self.viewModel.transform(input: input)
        
        output.weekDatas.asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] weekDatas in
                guard let self else { return }
                self.appendChartItem(weekDistances: weekDatas)
            }).disposed(by: disposeBag)
        
        output.recordSectionDatas.asDriver(onErrorJustReturn: ([], [:], [:], [:]))
            .drive (onNext: { [weak self] (allDates,
                                           totalDataAtDate,
                                           recordsAtData,
                                           mapNameAtMapId) in
                guard let self else { return }
                self.appendRecordItem(allDates: allDates,
                                      totalDataAtData: totalDataAtDate,
                                      recordsAtData: recordsAtData,
                                      mapNameAtMapId: mapNameAtMapId)
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
            $0.leading.equalTo(view.safeAreaLayoutGuide).inset(15)
            $0.trailing.equalTo(view.safeAreaLayoutGuide)
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
                
                let distances = recordViewChartDataArray.map { CGFloat($0.distance) }
                
                let frame = CGRect(x: 0,
                                   y: 0,
                                   width: cell.frame.width - 50,
                                   height: cell.frame.height - 45)
                let view = LineGraphView(frame: frame, values: distances)
                
                cell.subviews.forEach {
                    if $0 is LineGraphView {
                        $0.removeFromSuperview()
                    }
                }
                
                cell.addSubview(view)
                
                cell.bind(recordViewChartDataArray: recordViewChartDataArray)
                
                return cell
            case .myRecord(let record, let mapName):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecordMainCell.identifier,
                                                                    for: indexPath) as? RecordMainCell else {
                    return UICollectionViewCell()
                }
                cell.bind(mapName: mapName, record: record)
                
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
                
                let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
                header.bind(headerRecord: section.data)
                
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
        let groupInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 25)
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
    
    private func appendRecordItem(allDates: [String],
                                  totalDataAtData: [String: DayTotalRecord],
                                  recordsAtData: [String: [Record]],
                                  mapNameAtMapId: [Int: String]) {
        var snapshot = dataSource.snapshot()
        let previousSections = snapshot.sectionIdentifiers.filter { $0 != .chart }
        snapshot.deleteSections(previousSections)
        
        allDates.forEach { date in
            guard let totalData = totalDataAtData[date] else { return }
            let headerRecord = RecordViewHeaderRecord(date: date, distance: totalData.distance, kcal: totalData.calorie)
            snapshot.appendSections([.record(headerRecord)])
            
            recordsAtData[date]?.forEach({ record in
                guard let mapName = mapNameAtMapId[record.mapID] else { return }
                snapshot.appendItems([.myRecord(record, mapName)])
            })
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
}
