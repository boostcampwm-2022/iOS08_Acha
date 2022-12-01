//
//  MyPageViewController.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit
import SnapKit
import RxSwift

final class MyPageViewController: UIViewController {
    
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
    }
    
    enum MyPageItem: Hashable {
        case badge(badge: Badge)
        case setting(type: SettingType)
    }
    
    enum SettingType {
        case editInfo
        case logout
        case withDrawal
        case openSource
        
        var title: String {
            switch self {
            case .editInfo: return "내 정보 수정"
            case .logout: return "로그아웃"
            case .withDrawal: return "탈퇴하기"
            case .openSource: return "오픈소스 라이선스"
            }
        }
    }
    
    // MARK: - UI properties
    private var collectionView: UICollectionView!
    
    // MARK: - Properties
    typealias DataSource = UICollectionViewDiffableDataSource<MyPageSection, MyPageItem>
    private var dataSource: DataSource?
    private let viewModel: MyPageViewModel
    private var disposeBag = DisposeBag()
    
    private var badgeMoreButtonTapped = PublishSubject<Void>()
    private var editMyInfoTapped = PublishSubject<Void>()
    private var logoutTapped = PublishSubject<Void>()
    private var withDrawalTapped = PublishSubject<Void>()
    private var openSourceTapped = PublishSubject<Void>()
    
    // MARK: - Lifecycles
    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureUI()
        bind()
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
        navigationItem.title = "회원님, 안녕하세요!"
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
    
    private func bind() {
        let input = MyPageViewModel.Input(viewWillAppearEvent: rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:))).map { _ in },
                                          badgeMoreButtonTapped: badgeMoreButtonTapped,
                                          editMyInfoTapped: editMyInfoTapped,
                                          logoutTapped: logoutTapped,
                                          withDrawalTapped: withDrawalTapped,
                                          openSourceTapped: openSourceTapped)
        let output = viewModel.transform(input: input)
        
        output.nickName
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] nickName in
                guard let self else { return }
                self.navigationItem.title = "\(nickName)님, 안녕하세요!"
            }).disposed(by: disposeBag)
        
        output.badges
            .subscribe(onNext: { [weak self] badges in
                guard let self else { return }
                self.makeBadgeSnapshot(badges: badges)
            }).disposed(by: disposeBag)
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
        makeDefaultSnapshot()
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
                cell.bind(image: badge.imageURL, badgeName: badge.name, disposeBag: self.disposeBag)
                return cell 
            case .setting(let type):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: SettingCell.identifer,
                    for: indexPath) as? SettingCell else {
                    return SettingCell()
                }
                
                switch type {
                case .editInfo:
                    cell.bind(title: type.title) { [weak self] in
                        self?.editMyInfoTapped.onNext(())
                    }
                case .logout:
                    cell.bind(title: type.title) { [weak self] in
                        guard let self else { return }
                        self.showAlert(title: "로그아웃 하시겠습니까?",
                                       message: "",
                                       actionTitle: "확인",
                                       actionHandler: {
                            self.logoutTapped.onNext(())
                        })
                    }
                case .withDrawal:
                    cell.bind(title: type.title) { [weak self] in
                        guard let self else { return }
                        self.showAlert(title: "정말 탈퇴하시겠습니까?",
                                       message: "",
                                       actionTitle: "확인",
                                       actionHandler: {
                            self.withDrawalTapped.onNext(())
                        })
                    }
                case .openSource:
                    cell.bind(title: type.title) { [weak self] in
                        self?.openSourceTapped.onNext(())
                    }
                }
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
            switch sectionType {
            case .badge:
                header.bind(title: sectionType.title, moreButtonHandler: { [weak self] in
                    guard let self else { return }
                    self.badgeMoreButtonTapped.onNext(())
                })
            case .setting:
                header.bind(title: sectionType.title, moreButtonHandler: nil)
            }
            return header
        }
    }
    
    private func makeDefaultSnapshot() {
        guard let dataSource else { return }
        var snapshot = dataSource.snapshot()
        snapshot.appendSections([.badge, .setting])
        let settings: [MyPageItem] = [.setting(type: .editInfo),
                                      .setting(type: .logout),
                                      .setting(type: .withDrawal),
                                      .setting(type: .openSource)]
        snapshot.appendItems(settings, toSection: .setting)
        dataSource.apply(snapshot)
    }
    
    private func makeBadgeSnapshot(badges: [Badge]) {
        guard let dataSource else { return }
        var snapshot = dataSource.snapshot()
        let badgeItems = badges.map { MyPageItem.badge(badge: $0) }
        snapshot.appendItems(badgeItems, toSection: .badge)
        dataSource.apply(snapshot)
    }

}
