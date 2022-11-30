//
//  CommunityMainViewController.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit
import Then
import SnapKit

final class CommunityMainViewController: UIViewController {
    enum Section {
        case community
    }
    
    // MARK: - UI properties
    private var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    // MARK: - Properties
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Post>
    private var dataSource: DataSource!
    private let viewModel: CommunityMainViewModel!
    
    // MARK: - Lifecycles
    init(viewModel: CommunityMainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bind()

        snapshotUpdate(datas: [Post(id: 112321214,
                                    userID: "watwㅇㄴㅁㄹㅇho",
                                    nickName: "test0",
                                    text: "안녕하세요반가워요\n",
                                    image: "dawdad",
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
                                    image: "dadwad",
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
    
    // MARK: - Helpers
    private func bind() {
        let input = CommunityMainViewModel.Input(viewDidAppearEvent: rx.methodInvoked(#selector(viewDidAppear(_:)))
            .map({ _ in })
            .asObservable()
        )
        
        let output = viewModel.transform(input: input)
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        title = "커뮤니티"
        
        configureCollectionView()
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout()
        )
        collectionView.backgroundColor = .pointLight
        collectionView.register(CommunityMainCell.self,
                                forCellWithReuseIdentifier: CommunityMainCell.identifier)
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.top.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(15)
        }
        
        configureDataSource()
    }
    
    private func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView,
                                cellProvider: { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CommunityMainCell.identifier,
                for: indexPath) as? CommunityMainCell else {
                return UICollectionViewCell()
            }
            
            cell.bind(postData: itemIdentifier)
            
            return cell
        })
    }
    
    private func collectionViewLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    private func snapshotUpdate(datas: [Post]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendSections([.community])
        snapshot.appendItems(datas, toSection: .community)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}
