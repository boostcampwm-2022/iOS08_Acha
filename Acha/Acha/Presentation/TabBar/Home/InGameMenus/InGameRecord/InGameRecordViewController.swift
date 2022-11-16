//
//  GameRecordViewController.swift
//  Acha
//
//  Created by hong on 2022/11/15.
//

import UIKit

final class InGameRecordViewController: InGamePlayMenuView {

    // MARK: - UI properties
    // MARK: - Properties
    enum Section {
        case main
    }
    
    private lazy var recordDataSource: RecordDataSource = makeDataSource()
    
    typealias RecordDataSource = UICollectionViewDiffableDataSource<Section, InGameRecord>
    typealias RecordSnapShot = NSDiffableDataSourceSnapshot<Section, InGameRecord>
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "기록"
        collectionViewRegister()
    }
    
    // MARK: - Helpers
    private func collectionViewRegister() {
        collectionView.register(
            InGameMenuCollectionViewCell.self,
            forCellWithReuseIdentifier: InGameMenuCollectionViewCell.cellId
        )
    }
    
    private func makeDataSource() -> RecordDataSource {

        let datasource = RecordDataSource(
            collectionView: collectionView
        ) { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: InGameMenuCollectionViewCell.cellId,
                for: indexPath
            ) as? InGameMenuCollectionViewCell else {return UICollectionViewCell()}
            #warning("데이터 어떻게 보내줘야 할지 결정해야 함")
            cell.setData(
                image: nil,
                text: "\(itemIdentifier.date)    (\(itemIdentifier.time.convertToDayHourMinueFormat()))"
            )
            return cell
        }
        return datasource
    }
    
    func fetchData(data: [InGameRecord]) {
        var snapshot = RecordSnapShot()
        snapshot.appendSections([.main])
        snapshot.appendItems(data)
        recordDataSource.apply(snapshot, animatingDifferences: true)
    }
    
}

protocol InGameMenuModel {
    var time: Int {get set}
    var name: String {get set}
    var date: Date {get set}
}

struct InGameRecord: Hashable {
    let date: String
    let time: Int
}
