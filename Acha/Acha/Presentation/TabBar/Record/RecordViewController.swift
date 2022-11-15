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

struct Record: Hashable {
    var mapName: String
    var time: String
    var distance: String
    var mode: String
    var kcal: String
}

struct HeaderRecord: Hashable {
    var date: String
    var distance: String
    var kcal: String
}

enum RecordViewSections: Hashable, CaseIterable {
    case chart
    case myRecord
}

enum RecordViewItems: Hashable {
    case chart([Int])
    case myRecord(Record)
}

class RecordViewController: UIViewController, UICollectionViewDelegate {
    // MARK: - UI properties
    private var collectionView: UICollectionView!
    
    // MARK: - Properties
    typealias DataSource = UICollectionViewDiffableDataSource<RecordViewSections, RecordViewItems>
    private var dataSource: DataSource!
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        makeSnapshot()
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        
        navigationItem.title = "개인 기록"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor(named: "PointLightColor")]
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
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(15)
        }
        
        configureCollectionViewDataSource()
    }
    
    private func configureCollectionViewDataSource() {
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .chart(let distanceArray):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecordChartCell.identifier,
                                                                    for: indexPath) as? RecordChartCell else {
                    return UICollectionViewCell()
                }
                
                cell.bind(distanceArray: distanceArray)
                
                return cell
            case .myRecord(let record):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecordCell.identifier,
                                                                    for: indexPath) as? RecordCell else {
                    return UICollectionViewCell()
                }
                
                cell.bind(record: record)
                
                return cell
            }
        })
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                   withReuseIdentifier: RecordHeaderView.identifier,
                                                                             for: indexPath) as? RecordHeaderView
                else { return UICollectionReusableView() }
                
                switch indexPath.section {
                case 1:
                    let headerRecord = HeaderRecord(date: "2022년 12월 16일", distance: "뛴 거리 : 10.43km", kcal: "소비 칼로리 : 700kcal")
                    header.bind(headerRecord: headerRecord)
                    
                    return header
                default:
                    break
                }
                
                return header
            }
            return UICollectionReusableView()
        }
    }
    
    private func configureCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, _ ) -> NSCollectionLayoutSection? in
            let sectionLayoutKind = RecordViewSections.allCases[sectionIndex]
            
            switch sectionLayoutKind {
            case .chart:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .absolute(413))
                let groupInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                let sectionInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                
                return self.makeSectionLayout(itemSize: itemSize, groupSize: groupSize, groupInsets: groupInsets, sectionInsets: sectionInsets)
            case .myRecord:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .absolute(110))
                let groupInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10)
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .absolute(100))
                return self.makeSectionLayout(itemSize: itemSize, groupSize: groupSize, groupInsets: groupInsets, headerSize: headerSize)
            }
        }
        return layout
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
    
    private func makeSnapshot() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections(RecordViewSections.allCases)
        snapshot.appendItems([.chart([5, 2, 3, 4, 5, 6, 7])], toSection: .chart)
        snapshot.appendItems([.myRecord(Record(mapName: "벨루스 호텔", time: "시간: 00:10:05", distance: "거리: 2,424m", mode: "모드: 같이하기", kcal: "칼로리: 2020kcal")),
                              .myRecord(Record(mapName: "지하종합상가", time: "시간: 00:10:05", distance: "거리: 2,424m", mode: "모드: 같이하기", kcal: "칼로리: 2020kcal")),
                              .myRecord(Record(mapName: "승기님 집", time: "시간: 00:10:05", distance: "거리: 2,424m", mode: "모드: 같이하기", kcal: "칼로리: 2020kcal"))],
                             toSection: .myRecord)
        
        dataSource.apply(snapshot)
    }
}
