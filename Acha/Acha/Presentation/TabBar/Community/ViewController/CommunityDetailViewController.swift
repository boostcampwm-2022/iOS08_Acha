//
//  CommunityDetailViewController.swift
//  Acha
//
//  Created by hong on 2022/11/29.
//

import UIKit

final class CommunityDetailViewController: UIViewController {
    
    enum Section: Int {
        case post = 0
        case comment = 1
    }
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    )
    
    typealias Datasource = UICollectionViewDiffableDataSource<Section, AnyHashable>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>
    
    private lazy var dataSource = makeDataSource()
    private lazy var snapShot = Snapshot()

    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
    }

}

extension CommunityDetailViewController {
    private func layout() {
        addViews()
        addConstraints()
        configureCollectionView()
    }
    
    private func addViews() {
        
    }
    
    private func addConstraints() {
        
    }

}

extension CommunityDetailViewController {
    
    private func configureCollectionView() {
        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: compositionalLayout()
        )
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    
    private func makeDataSource() -> Datasource {
        let datasource = Datasource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            if let post = itemIdentifier as? Post {
                let cell = UICollectionViewCell()
                return cell
            } else if let comment = itemIdentifier as? Comment {
                let cell = UICollectionViewCell()
                return cell
            } else {
                fatalError("Unknown Cell Type")
            }
        }
        snapShot.appendSections([.post, .comment])
        return datasource
    }
    
    private func configureHeader() {
        
    }
    
    private func registerCollectionView() {
        collectionView.register(
            CommentCollectionViewCell.self,
            forCellWithReuseIdentifier: CommentCollectionViewCell.identifier
        )
        
        collectionView.register(
            PostCollectionViewCell.self,
            forCellWithReuseIdentifier: PostCollectionViewCell.identifier
        )
        
        collectionView.register(
            PostHeaderCollectionReusableView.self,
            forCellWithReuseIdentifier: PostHeaderCollectionReusableView.identifier
        )
        
        collectionView.register(
            CommentHeaderCollectionReusableView.self,
            forCellWithReuseIdentifier: CommentHeaderCollectionReusableView.identifier
        )
    }
    
    private func makeSnapshot(datas: [AnyHashable], section: Section) {
        let oldItems = snapShot.itemIdentifiers(inSection: section)
        snapShot.deleteItems(datas)
        snapShot.appendItems(datas, toSection: section)
        dataSource.apply(snapShot, animatingDifferences: true)
    }
    
    private func compositionalLayout() -> UICollectionViewCompositionalLayout {
        
        let sectionProvider = { (
            sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment
        ) -> NSCollectionLayoutSection? in
            guard let sectionKind = Section(rawValue: sectionIndex) else {return nil}
            let section: NSCollectionLayoutSection
            switch sectionKind {
            case .post:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.9),
                    heightDimension: .estimated(300)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(300)
                )
                let group = NSCollectionLayoutGroup(layoutSize: groupSize)
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(100)
                )
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header]
            case .comment:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.9),
                    heightDimension: .estimated(300)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(300)
                )
                let group = NSCollectionLayoutGroup(layoutSize: groupSize)
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(100)
                )
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header]
            }
            return section
        }
        
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}
