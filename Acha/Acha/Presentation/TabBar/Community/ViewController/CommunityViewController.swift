//
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
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    private lazy var postWriteBarButton = UIButton().then {
        $0.setImage(.pencilCircleFill, for: .normal)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 50)
        $0.setPreferredSymbolConfiguration(imageConfig, forImageIn: .normal)
    }
    
    typealias CommunityDatasource = UICollectionViewDiffableDataSource<Section, Post>
    typealias CommunitySnapShot = NSDiffableDataSourceSnapshot<Section, Post>
    
    private lazy var communitDataSource = makeDataSource()
    private lazy var communitySnapshot = CommunitySnapShot()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "커뮤니티"
        configureCollectionView()
        configurePostWriteButton()

        snapshotUpdate(datas: [Post(id: 112321214,
                                    userID: "watwㅇㄴㅁㄹㅇho",
                                    nickName: "test0",
                                    text: "안녕하세요반가워요\n",
                                    image: nil,
                                    createdAt: Date(),
                                    commentCount: 23),
                               Post(id: 121214,
                                    userID: "waho",
                                    nickName: "test1",
                                    text: "안녕하세요반가워요\n테스트중입니다\nㅠㅠ",
                                    image: nil,
                                    createdAt: Date(),
                                    commentCount: 23),
                               Post(id: 1214,
                                    userID: "이야호",
                                    nickName: "test2",
                                    text: "안녕하세요반가워요\n테스트중입니다\nㅠㅠ",
                                    image: nil,
                                    createdAt: Date(),
                                    commentCount: 23),
                               Post(id: 121214,
                                    userID: "와오",
                                    nickName: "test3",
                                    text: "안녕하세요반가워요\n테스트중입니다\nㅠㅠ",
                                    image: nil,
                                    createdAt: Date(),
                                    commentCount: 23)])

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
    
    private func configurePostWriteButton() {
        view.addSubview(postWriteBarButton)
        postWriteBarButton.snp.makeConstraints {
            $0.bottom.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.width.equalTo(50)
        }
    }
}
