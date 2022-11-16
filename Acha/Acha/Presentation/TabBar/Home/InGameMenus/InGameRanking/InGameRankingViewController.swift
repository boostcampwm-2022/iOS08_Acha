//
//  GameRankingViewController.swift
//  Acha
//
//  Created by hong on 2022/11/15.
//

import UIKit

final class InGameRankingViewController: InGamePlayMenuView {
    // MARK: - UI properties
    // MARK: - Properties

    enum Section {
        case main
    }
    
    private lazy var rankingDataSource: RankingDataSource = makeDataSource()
    
    typealias RankingDataSource = UICollectionViewDiffableDataSource<Section, InGameRanking>
    typealias RankingSnapShot = NSDiffableDataSourceSnapshot<Section, InGameRanking>
    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewRegister()
    }
    // MARK: - Helpers
    private func collectionViewRegister() {
        collectionView.register(
            InGameMenuCollectionViewCell.self,
            forCellWithReuseIdentifier: InGameMenuCollectionViewCell.cellId
        )
    }
    private func makeDataSource() -> RankingDataSource {

        let datasource = RankingDataSource(
            collectionView:
                collectionView
        ) { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: InGameMenuCollectionViewCell.cellId,
                for: indexPath
            ) as? InGameMenuCollectionViewCell else {return UICollectionViewCell()}
            #warning("데이터 어떻게 보내줄지 결정해야 함")
            cell.setData(
                image: UIImage(named: "rank\(indexPath.row)"),
                text: itemIdentifier.name+"(\(itemIdentifier.time.convertToDayHourMinueFormat()))"
            )
            return cell
        }
        return datasource
    }
    
    func fetchData(data: [InGameRanking]) {
        var snapshot = RankingSnapShot()
        snapshot.appendSections([.main])
        snapshot.appendItems(data)
        rankingDataSource.apply(snapshot, animatingDifferences: true)
    }
}

struct InGameRanking: Hashable {
    let name: String
    let time: Int
}
