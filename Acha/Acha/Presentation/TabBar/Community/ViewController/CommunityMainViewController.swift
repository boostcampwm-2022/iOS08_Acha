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

final class CommunityMainViewController: UIViewController {
    enum Section {
        case community
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
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Post>
    private var dataSource: DataSource!
    private let viewModel: CommunityMainViewModel!
    private let disposeBag = DisposeBag()
    
    private var cellTapEvent = PublishRelay<Int>()
    private var rightButtonTapEvent = PublishRelay<Void>()
    
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
        print(#function)
    }
    
    // MARK: - Helpers
    private func bind() {
        let input = CommunityMainViewModel.Input(
            viewDidAppearEvent: rx.methodInvoked(#selector(viewDidAppear(_:)))
                .map({ _ in })
                .asObservable(),
            cellTapEvent: self.cellTapEvent.asObservable(),
            rightButtonTapEvent: self.rightButtonTapEvent.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.posts
            .subscribe(onNext: { [weak self] posts in
                guard let self else { return }
                self.updateSnapshot(posts: posts)
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
        collectionView.delegate = self
        collectionView.register(CommunityMainCell.self,
                                forCellWithReuseIdentifier: CommunityMainCell.identifier)
        collectionView.backgroundColor = .white
        
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
            cell.bind(post: itemIdentifier)
            
            return cell
        })
    }
    
    private func collectionViewLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(130)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(130)
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
    
    private func updateSnapshot(posts: [Post]) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteSections([.community])

        snapshot.appendSections([.community])
        snapshot.appendItems(posts, toSection: .community)
        dataSource.apply(snapshot)
    }
    
    private func deleteSnapshot() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteSections([.community])
        dataSource.apply(snapshot)
    }
    
    @objc private func rightButtonTapped() {
        self.rightButtonTapEvent.accept(())
    }
}

extension CommunityMainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        cellTapEvent.accept(indexPath.row)
    }
}
