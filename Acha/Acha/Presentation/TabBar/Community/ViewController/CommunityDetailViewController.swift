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
    
    private lazy var commentView = CommentView()
    
    typealias Datasource = UICollectionViewDiffableDataSource<Section, AnyHashable>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>
    
    private lazy var dataSource = makeDataSource()
    private lazy var snapShot = Snapshot()

    // 더미 데이터
    let postData = Post(id: 123,
                        userID: "q3qrw",
                        nickName: "qwwqt",
                        text: "waetatwe\nwetwa\nwaeatw\n",
                        image: "atwwt", createdAt: Date(),
                        commentCount: 142)
    let commentData = Comment(postID: 124,
                              userID: "wataw",
                              nickName: "awetawtatw",
                              text: "테스트테스트\n테스트\n테스트테스트\n테스트\n테스트테스트\n테스트\n",
                              createdAt: Date())
    
    let commentData2 = Comment(postID: 14,
                              userID: "wataw",
                              nickName: "awetawtatw",
                              text: "테스트테스트\n테스트\n테스트테스트\n테스트\n테스트테스트\n테스트\n",
                              createdAt: Date())
    
    let commentData3 = Comment(postID: 123,
                              userID: "wataw",
                              nickName: "awetawtatw",
                              text: "테스트테스트\n테스트\n테스트테스트\n테스트\n테스트테스트\n테스트\n",
                              createdAt: Date())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "게시글"
        view.backgroundColor = .white
        layout()
        makeSnapshot(datas: [postData], section: .post)
        makeSnapshot(datas: [commentData, commentData2, commentData3], section: .comment)
        bindText()
    }
    
    private func bindText() {
        KeyboardManager.keyboardWillHide(view: commentView, superView: view)
        KeyboardManager.keyboardWillShow(view: commentView, superView: view)
        hideKeyboardWhenTapped()
    }

}

extension CommunityDetailViewController {
    private func layout() {
        addViews()
        addConstraints()
        configureCollectionView()
    }
    
    private func addViews() {
        view.addSubview(commentView)
    }
    
    private func addConstraints() {
        commentView.snp.makeConstraints {
            $0.trailing.leading.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(100)
        }
    }

}

extension CommunityDetailViewController {
    
    private func configureCollectionView() {
        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: compositionalLayout()
        )
        snapShot.appendSections([.post, .comment])
        registerCollectionView()
        configureCollectionViewHeader()
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.layoutMarginsGuide)
            $0.bottom.equalTo(commentView.snp.top)
        }
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .pointDark
    }

    private func makeDataSource() -> Datasource {
 
        let datasource = Datasource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            guard let section = Section(rawValue: indexPath.section) else {return UICollectionViewCell()}
            if let post = itemIdentifier as? Post {
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PostCollectionViewCell.identifier,
                    for: indexPath
                ) as? PostCollectionViewCell else {return UICollectionViewCell()}
                cell.bindData(data: post)
                self.cellLayoutAdjust(section: section, cell: cell, indexPath: indexPath)
                return cell
            } else if let comment = itemIdentifier as? Comment {
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CommentCollectionViewCell.identifier,
                    for: indexPath
                ) as? CommentCollectionViewCell else {return UICollectionViewCell()}
                cell.bindData(data: comment)
                self.cellLayoutAdjust(section: section, cell: cell, indexPath: indexPath)
                return cell
            } else {
                fatalError("Unknown Cell Type")
            }
        }
        return datasource
    }
    
    private func cellLayoutAdjust(section: Section, cell: UICollectionViewCell, indexPath: IndexPath) {
        cell.backgroundColor = .white
        switch section {
        case .post:
            if indexPath.row == 0 {
                cell.layer.addBorder(directions: [.top], color: .pointLight, width: 1)
            }
            cell.backgroundColor = .white
        case .comment:
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.pointLight.cgColor
            cell.backgroundColor = .white
            cell.layer.cornerRadius = 5
        }
    }
    
    private func configureCollectionViewHeader() {
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            guard elementKind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
            guard let selectionKind = Section(rawValue: indexPath.section) else { return UICollectionReusableView() }
            
            switch selectionKind {
            case .post:
                guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: elementKind,
                    withReuseIdentifier: PostHeaderCollectionReusableView.identifier,
                    for: indexPath) as? PostHeaderCollectionReusableView else { return UICollectionReusableView() }
                header.bindData(data: self.postData)
                header.layer.addBorder(directions: [.top], color: .pointLight, width: 1)
                header.backgroundColor = .white
                    return header
            case .comment:
                guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: elementKind,
                    withReuseIdentifier: CommentHeaderCollectionReusableView.identifier,
                    for: indexPath) as? CommentHeaderCollectionReusableView else { return UICollectionReusableView() }
                header.backgroundColor = .white
                    return header
            }
        }
    }
    
    private func registerCollectionView() {
        collectionView.register(
            PostHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PostHeaderCollectionReusableView.identifier
        )
        
        collectionView.register(
            CommentHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CommentHeaderCollectionReusableView.identifier
        )
        collectionView.register(
            CommentCollectionViewCell.self,
            forCellWithReuseIdentifier: CommentCollectionViewCell.identifier
        )
        
        collectionView.register(
            PostCollectionViewCell.self,
            forCellWithReuseIdentifier: PostCollectionViewCell.identifier
        )
    }
    
    private func makeSnapshot(datas: [AnyHashable], section: Section) {
        let oldItems = snapShot.itemIdentifiers(inSection: section)
        snapShot.deleteItems(oldItems)
        snapShot.appendItems(datas, toSection: section)
        dataSource.apply(snapShot, animatingDifferences: true)
    }
    
    private func compositionalLayout() -> UICollectionViewCompositionalLayout {
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, _ ) -> NSCollectionLayoutSection? in
   
            guard let sectionKind = Section(rawValue: sectionIndex) else {return nil}
            let section: NSCollectionLayoutSection
            switch sectionKind {
            case .post:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(300)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(300)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(50)
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
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(300)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 5, bottom: 5, trailing: 5)
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(300)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
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
                section.interGroupSpacing = 5
                section.boundarySupplementaryItems = [header]
            }
            return section
        }
        
        return layout
    }
    
    private func bindPostHeader(data: Post) {
        guard let header = collectionView.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(row: 0, section: 0)
        ) as? PostHeaderCollectionReusableView else {return}
        header.bindData(data: data)
    }
}

extension CommunityDetailViewController {
    private func hideKeyboardWhenTapped() {
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
