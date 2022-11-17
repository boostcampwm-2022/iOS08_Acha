//
//  GameRecordViewController.swift
//  Acha
//
//  Created by hong on 2022/11/15.
//

import UIKit

final class InGameRecordViewController: InGamePlayMenuViewController {

    // MARK: - UI properties
    // MARK: - Properties
    enum Section {
        case main
    }
    
    private lazy var recordDataSource: RecordDataSource = configureDataSource()
    
    typealias RecordDataSource = UICollectionViewDiffableDataSource<Section, InGameRecord>
    typealias RecordSnapShot = NSDiffableDataSourceSnapshot<Section, InGameRecord>
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "기록"
        collectionViewRegister()
    }
    
    // MARK: - Helpers
    private func collectionViewRegister() {
        collectionView.register(
            InGameMenuCollectionViewCell.self,
            forCellWithReuseIdentifier: InGameMenuCollectionViewCell.identifier
        )
    }
    
    private func configureDataSource() -> RecordDataSource {

        let datasource = RecordDataSource(
            collectionView: collectionView
        ) { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: InGameMenuCollectionViewCell.identifier,
                for: indexPath
            ) as? InGameMenuCollectionViewCell else {return UICollectionViewCell()}
            #warning("데이터 어떻게 보내줘야 할지 결정해야 함")
            cell.setData(
                image: nil,
                text: "\(itemIdentifier.date.convertToStringFormat(format: "yyyy년 MM월 dd일 EEE요일")) \(itemIdentifier.time.convertToDayHourMinueFormat())"
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

struct InGameRecord: Hashable, InGameMenuModelProtocol {
    var time: Int
    var userName: String
    var date: Date
}
