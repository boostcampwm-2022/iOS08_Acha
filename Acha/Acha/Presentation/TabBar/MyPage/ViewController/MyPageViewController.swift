//
//  MyPageViewController.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit
import SnapKit

class MyPageViewController: UIViewController {
    
    enum MyPageSection: Int {
        case badge
        case setting
        
        var title: String {
            switch self {
            case .badge:
                return "획득한 뱃지"
            case .setting:
                return "설정"
            }
        }
        
        var isHiddenMoreButton: Bool {
            switch self {
            case .badge:
                return false
            case .setting:
                return true
            }
        }
    }
    
    enum MyPageItem: Hashable {
        case badge(badge: Badge)
        case setting(title: String)
    }
    
    // MARK: - UI properties
    private var collectionView: UICollectionView!
    
    // MARK: - Properties
    typealias DataSource = UICollectionViewDiffableDataSource<MyPageSection, MyPageItem>
    private var dataSource: DataSource?
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureUI()
    }
}

// MARK: - Helpers
extension MyPageViewController {
    
    private func configureUI() {
        view.backgroundColor = .white
        configureNavigationTitle()
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func configureNavigationTitle() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        #warning("title 수정")
        navigationItem.title = "옹이님, 안녕하세요!"
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: UIColor.pointLight
        ]
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: configureCollectionViewLayout())
        collectionView.backgroundColor = .white
        
        collectionView.register(BadgeCell.self,
                                forCellWithReuseIdentifier: BadgeCell.identifer)
        collectionView.register(SettingCell.self,
                                forCellWithReuseIdentifier: SettingCell.identifer)
        collectionView.register(MyPageHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: MyPageHeaderView.identifer)
        configureDataSource()
    }
}

// MARK: - CollectionView Layout

extension MyPageViewController {
    private func configureCollectionViewLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] (sectionIndex: Int, _) -> NSCollectionLayoutSection? in
            guard let self,
                  let sectionType = MyPageSection(rawValue: sectionIndex) else { return nil }
            switch sectionType {
            case .badge:
                return self.configureBadgeLayout()
            case .setting:
                return self.configureSettingLayout()
            }
        }
    }
    
    private func configureBadgeLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1/3),
            heightDimension: .absolute(145))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let itemInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        item.contentInsets = itemInsets
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(145))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(40))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        let headerInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        header.contentInsets = headerInsets
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header]
        return section
    }
    
    private func configureSettingLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(40))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let itemInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        item.contentInsets = itemInsets
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(40))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(40))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        let headerInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        header.contentInsets = headerInsets
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header]
        return section
    }
}

// MARK: - CollectionView Layout
extension MyPageViewController {
    
    private func configureDataSource() {
        configureItemDataSource()
        configureHeaderDataSource()
        makeSnapshot()
    }
    
    private func configureItemDataSource() {
        dataSource = DataSource(collectionView: collectionView,
                                cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell in
            switch item {
            case .badge(let badge):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: BadgeCell.identifer,
                    for: indexPath) as? BadgeCell else {
                    return BadgeCell()
                }
                #warning("image Data(contentsOf:)로 받아오기")
                let badgeImage = UIImage.penguinImage
                cell.bind(image: badgeImage, badgeName: badge.name)
                return cell 
            case .setting(let title):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: SettingCell.identifer,
                    for: indexPath) as? SettingCell else {
                    return SettingCell()
                }
                cell.bind(title: title)
                return cell
            }
        })
    }
    
    private func configureHeaderDataSource() {
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader,
                  let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: MyPageHeaderView.identifer,
                    for: indexPath) as? MyPageHeaderView
            else { return UICollectionReusableView() }
            
            guard let sectionType = MyPageSection(rawValue: indexPath.section) else { return header }
            header.bind(title: sectionType.title, isHiddenMoreButton: sectionType.isHiddenMoreButton)
            return header
        }
    }
    
    private func makeSnapshot() {
        guard let dataSource else { return }
        var snapshot = dataSource.snapshot()
        snapshot.appendSections([.badge, .setting])
        let badges: [MyPageItem] = [.badge(badge: Badge(id: 0, name: "너짱", image: Data(), isHidden: false)),
                                    .badge(badge: Badge(id: 1, name: "달리기왕", image: Data(), isHidden: false)),
                                    .badge(badge: Badge(id: 2, name: "55등", image: Data(), isHidden: true))]
        snapshot.appendItems(badges, toSection: .badge)
        let settings: [MyPageItem] = [.setting(title: "내 정보 수정"),
                                      .setting(title: "로그아웃"),
                                      .setting(title: "탈퇴하기"),
                                      .setting(title: "오픈소스 라이선스")]
        snapshot.appendItems(settings, toSection: .setting)
        dataSource.apply(snapshot)
    }

}
