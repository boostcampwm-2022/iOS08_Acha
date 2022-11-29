//
//  CommunityDetailViewController.swift
//  Acha
//
//  Created by hong on 2022/11/29.
//

import UIKit

final class CommunityDetailViewController: UIViewController {
    
    enum Section: String {
        case post = "Post"
        case comment = "Comment"
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
    }
    
    private func addViews() {
        
    }
    
    private func addConstraints() {
        
    }

}

extension CommunityDetailViewController {
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
    
    private func makeSnapshot() {
        
    }
}
