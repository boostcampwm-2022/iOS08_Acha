//
//  BadgeViewController.swift
//  Acha
//
//  Created by 조승기 on 2022/11/30.
//

import UIKit
import Then
import SnapKit
import RxSwift

class BadgeViewController: UIViewController {
    // MARK: - UI properties
    private var collectionView: UICollectionView!
    // MARK: - Properties
    enum BadgeSection: Int {
        case brandNew
        case acquired
        case unacquired
        
        var title: String {
            switch self {
            case .brandNew:
                return "최근 달성 기록"
            case .acquired:
                return "획득한 뱃지"
            case .unacquired:
                return "미획득한 뱃지"
            }
        }
    }
    let viewModel: BadgeViewModel
    typealias DataSource = UICollectionViewDiffableDataSource<BadgeSection, Badge>
    private var dataSource: DataSource?
    private var disposeBag = DisposeBag()
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
    
    init(viewModel: BadgeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Helpers
    private func setupSubviews() {
        navigationItem.title = "뱃지"
        cofigureCollectionView()
        bind()
    }
    
    private func cofigureCollectionView() {
        collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: configureCollectionViewLayout())
        
        collectionView.register(BadgeCell.self,
                                forCellWithReuseIdentifier: BadgeCell.identifer)
        collectionView.register(MyPageHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: MyPageHeaderView.identifer)
        collectionView.backgroundColor = .white
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview() 
        }
        configureDataSource()
    }
    
    private func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView,
                                cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: BadgeCell.identifer,
                for: indexPath) as? BadgeCell else {
                return BadgeCell()
            }
            cell.bind(badge: item)
            return cell
        })
        configureHeaderDataSource()
        makeDefaultSnapshot()
    }
    private func configureHeaderDataSource() {
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader,
                  let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: MyPageHeaderView.identifer,
                    for: indexPath) as? MyPageHeaderView
            else { return UICollectionReusableView() }
            
            guard let sectionType = BadgeSection(rawValue: indexPath.section) else { return header }
            header.bind(title: sectionType.title, moreButtonHandler: nil)
            return header
        }
    }
    
    private func configureCollectionViewLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { (_, _ ) -> NSCollectionLayoutSection in
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
    }
    
    private func bind() {
        let output = viewModel.transform(input: BadgeViewModel.Input())
        output.brandNewBadges
            .subscribe(onNext: { [weak self] badges in
                guard let self else { return }
                self.makeBadgeSnapShot(badges: badges, section: .brandNew)
            }).disposed(by: disposeBag)
        output.aquiredBadges
            .subscribe(onNext: { [weak self] badges in
                guard let self else { return }
                self.makeBadgeSnapShot(badges: badges, section: .acquired)
            }).disposed(by: disposeBag)
        output.inaquiredBadges
            .subscribe(onNext: { [weak self] badges in
                guard let self else { return }
                self.makeBadgeSnapShot(badges: badges, section: .unacquired)
            }).disposed(by: disposeBag)
    }
    
    private func makeDefaultSnapshot() {
        guard let dataSource else { return }
        var snapshot = dataSource.snapshot()
        snapshot.appendSections([.brandNew, .acquired, .unacquired])
        dataSource.apply(snapshot)
    }
    
    private func makeBadgeSnapShot(badges: [Badge], section: BadgeSection) {
        guard let dataSource else { return }
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(badges, toSection: section)
        dataSource.apply(snapshot)
    }
}
