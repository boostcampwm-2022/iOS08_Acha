//
//  CommunityMainViewController.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxRelay

final class CommunityMainViewController: UIViewController, UICollectionViewDelegate {
    enum Section {
        case community
    }
    
    enum Item: Hashable {
        case community(Post)
        case indicator
        
        var data: Post? {
            switch self {
            case.community(let post):
                return post
            default:
                return nil
            }
        }
    }
    
    // MARK: - UI properties
    private var collectionView: UICollectionView!
    private lazy var rightButton: UIBarButtonItem = UIBarButtonItem().then {
        $0.title = "글 작성"
        $0.style = .plain
        $0.target = self
        $0.action = #selector(rightButtonTapped)
        $0.tintColor = .pointLight
        $0.setTitleTextAttributes([.font: UIFont.defaultTitle ], for: .normal)
    }
    
    // MARK: - Properties
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    private var dataSource: DataSource!
    private let viewModel: CommunityMainViewModel!
    private let disposeBag = DisposeBag()
    
    private var cellTapEvent = PublishRelay<Int>()
    private var rightButtonTapEvent = PublishRelay<Void>()
    private var cellReloadEvent = PublishRelay<Int>()
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        deleteSnapshot()
    }
    
    // MARK: - Helpers
    private func bind() {
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self,
                      let cell = self.collectionView.cellForItem(at: indexPath) as? CommunityMainCell else { return }
                self.cellTapEvent.accept(cell.id)
            }).disposed(by: disposeBag)
        
        let input = CommunityMainViewModel.Input(
            viewDidAppearEvent: rx.methodInvoked(#selector(viewDidAppear(_:)))
                .map({ _ in })
                .asObservable(),
            cellTapEvent: self.cellTapEvent.asObservable(),
            rightButtonTapEvent: self.rightButtonTapEvent.asObservable(),
            cellReloadEvent: self.cellReloadEvent.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.posts
            .subscribe(onNext: { [weak self] posts in
                guard let self else { return }
                if self.dataSource.snapshot().itemIdentifiers.isEmpty {
                    self.makeSnapshot(posts: posts)
                } else {
                    self.updateSnapshot(posts: posts)
                }
            })
            .disposed(by: disposeBag)
        
        output.reloadEvent
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.reloadSnapshot()
                self.collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "커뮤니티"
        navigationItem.rightBarButtonItem = rightButton
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.pointLight]
        
        configureCollectionView()
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: collectionViewLayout())
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(CommunityMainCell.self,
                                forCellWithReuseIdentifier: CommunityMainCell.identifier)
        collectionView.register(CommunityIndicatorCell.self,
                                forCellWithReuseIdentifier: CommunityIndicatorCell.identifier)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.top.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(15)
        }
        
        configureDataSource()
    }
    
    private func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView,
                                cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
            guard let self else { return UICollectionViewCell() }
            switch itemIdentifier {
            case .community(let post):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CommunityMainCell.identifier,
                    for: indexPath) as? CommunityMainCell else {
                    return UICollectionViewCell()
                }
                cell.bind(post: post)
                cell.textViewTapEvent?.subscribe(onNext: { postID in
                    self.cellTapEvent.accept(postID)
                }).disposed(by: self.disposeBag)
                return cell
            case .indicator:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CommunityIndicatorCell.identifier,
                    for: indexPath) as? CommunityIndicatorCell else {
                    return UICollectionViewCell()
                }
                
                cell.indicatorView.startAnimating()
                return cell
            }
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
        section.interGroupSpacing = 5
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    private func makeSnapshot(posts: [Post]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        snapshot.appendSections([.community])
        if posts.count >= 3 {
            snapshot.appendItems([.indicator], toSection: .community)
        }
        
        posts.forEach {
            snapshot.insertItems([.community($0)], beforeItem: .indicator)
        }
        dataSource.apply(snapshot)
    }
    
    private func updateSnapshot(posts: [Post]) {
        var snapshot = dataSource.snapshot()
        
        posts.forEach {
            snapshot.insertItems([.community($0)], beforeItem: .indicator)
        }
        dataSource.apply(snapshot)
    }
    
    private func reloadSnapshot() {
        var snapshot = dataSource.snapshot()
        snapshot.reloadSections([.community])
        dataSource.apply(snapshot)
    }
    
    private func deleteSnapshot() {
        var snapshot = dataSource.snapshot()
        if snapshot.itemIdentifiers.count > 5 {
            snapshot.deleteItems(Array(snapshot.itemIdentifiers[5...]))
        }
        dataSource.apply(snapshot)
    }
    
    @objc private func rightButtonTapped() {
        self.rightButtonTapEvent.accept(())
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if indexPath.row == collectionView.numberOfItems(inSection: indexPath.section)-1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let itemCount = self.dataSource.snapshot().numberOfItems
                if itemCount > 1 {
                    let lastCellIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
                    guard let cell = self.collectionView.cellForItem(at: lastCellIndexPath)
                            as? CommunityMainCell else { return }
                    self.cellReloadEvent.accept(cell.id)
                }
            }
        }
    }
}
