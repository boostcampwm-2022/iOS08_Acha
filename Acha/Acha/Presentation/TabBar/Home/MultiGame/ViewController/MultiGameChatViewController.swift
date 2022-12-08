//
//  MultiGameChatViewController.swift
//  Acha
//
//  Created by hong on 2022/12/08.
//

import UIKit
import Then
import SnapKit

final class MultiGameChatViewController: UIViewController {
    
    enum Section {
        case chat
    }
    private lazy var chatCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    private lazy var commentView = CommentView()

    typealias ChatDataSource = UICollectionViewDiffableDataSource<Section, Chat>
    typealias ChatSnapShot = NSDiffableDataSourceSnapshot<Section, Chat>
    
    private lazy var chatDataSource = makeDataSource()
    private lazy var chatSnapShot = ChatSnapShot()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureCommentView()
    }
    
    private func configureCommentView() {
        view.addSubview(commentView)
        commentView.snp.makeConstraints {
            $0.leading.equalTo(view.snp.centerX)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(80)
        }
    }
}

extension MultiGameChatViewController {
    private func makeDataSource() -> ChatDataSource {
        let dataSource = ChatDataSource(
            collectionView: chatCollectionView
        ) { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ChatCell.identifier,
                for: indexPath
            ) as? ChatCell else {return UICollectionViewCell()}
            cell.bind(data: itemIdentifier)
            return cell
        }
        return dataSource
    }
    
    private func makeSnapShot(data: [Chat]) {
        let oldItems = chatSnapShot.itemIdentifiers(inSection: .chat)
        chatSnapShot.deleteItems(oldItems)
        chatSnapShot.appendItems(data, toSection: .chat)
        chatDataSource.apply(chatSnapShot, animatingDifferences: true)
    }
    
    private func registerCollectionView() {
        chatCollectionView.register(
            ChatCell.self,
            forCellWithReuseIdentifier: ChatCell.identifier
        )
    }
    
    private func configureCollectionView() {
        chatCollectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCompositonLayout())
        view.addSubview(chatCollectionView)
        registerCollectionView()
        chatCollectionView.backgroundColor = .white
        chatCollectionView.snp.makeConstraints {
            $0.leading.equalTo(view.snp.centerX)
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(80)
        }
        chatSnapShot.appendSections([.chat])
    }
    
    private func makeCompositonLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(50)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(50)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}
