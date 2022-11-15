//
//  GameRankingViewController.swift
//  Acha
//
//  Created by hong on 2022/11/15.
//

import UIKit

final class GameRankingViewController: GamePlayMenuView {
    
    enum Section {
        case main
    }
    
    private lazy var rankingDataSource: RankingDataSource = makeDataSource()
    
    typealias RankingDataSource = UICollectionViewDiffableDataSource<Section, InGameRanking>
    typealias RankingSnapShot = NSDiffableDataSourceSnapshot<Section, InGameRanking>

    override func viewDidLoad() {
        super.viewDidLoad()
        registerCollection()
    }
    
    private func registerCollection() {
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    private func makeDataSource() -> RankingDataSource {
        let datasource = RankingDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            return cell
        }
        return datasource
    }
    
    private func fetchData(data: [InGameRanking]) {
        var snapshot = RankingSnapShot()
        snapshot.appendSections([.main])
        snapshot.appendItems(data)
        rankingDataSource.apply(snapshot)
    }
    
}


struct InGameRanking: Hashable {
    let name: String
    let time: Int
}
