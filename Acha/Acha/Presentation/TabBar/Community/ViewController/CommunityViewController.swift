
//  CommunityViewController.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit
import Then
import SnapKit

final class CommunityViewController: UIViewController {

    enum Section {
        case community
    }

    private var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )

    typealias CommunityDatasource = UICollectionViewDiffableDataSource<Section, Post>
    typealias CommunitySnapShot = NSDiffableDataSourceSnapshot<Section, Post>

    private lazy var communitDataSource = makeDataSource()
    private lazy var communitySnapshot = CommunitySnapShot()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "커뮤니티"
        configureCollectionView()

    }

}

extension CommunityViewController {
    private func makeDataSource() -> CommunityDatasource {
        let dataSource = CommunityDatasource(
            collectionView: collectionView
        ) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CommunityCollectionViewCell.identifier,
                for: indexPath
            ) as? CommunityCollectionViewCell
            cell?.bindData(data: itemIdentifier)
            return cell
        }
        return dataSource
    }

    private func compositonLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(300)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(300)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        let layout = UICollectionViewCompositionalLayout(section: section)

        return layout
    }

    private func registerCollectioView() {
        collectionView.register(
            CommunityCollectionViewCell.self,
            forCellWithReuseIdentifier: CommunityCollectionViewCell.identifier
        )
    }

    private func configureCollectionView() {
        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: compositonLayout()
        )
        collectionView.dragInteractionEnabled = false
        collectionView.backgroundColor = .pointLight
        registerCollectioView()
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        communitySnapshot.appendSections([.community])
    }

    private func snapshotUpdate(datas: [Post]) {
        let oldItems = communitySnapshot.itemIdentifiers(inSection: .community)
        communitySnapshot.deleteItems(oldItems)
        communitySnapshot.appendItems(datas, toSection: .community)
        communitDataSource.apply(communitySnapshot, animatingDifferences: true)
    }

}
