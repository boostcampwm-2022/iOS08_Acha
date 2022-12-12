//
//  CharacterSelectViewController.swift
//  Acha
//
//  Created by  sangyeon on 2022/12/11.
//

import UIKit
import RxSwift
import SnapKit

final class CharacterSelectViewController: UIViewController {
    
    enum Section {
        case badges
    }
    // MARK: - UI properties
    private var collectionView: UICollectionView!
    
    // MARK: - Properties
    private let viewModel: CharacterSelectViewModel
    private var disposeBag = DisposeBag()
    private let finishButtonTapped = PublishSubject<Void>()
    private let cancelButtonTapped = PublishSubject<Void>()
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Badge>
    private var dataSource: DataSource?
    
    // MARK: - Lifecycles
    init(viewModel: CharacterSelectViewModel) {
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

extension CharacterSelectViewController {
    // MARK: - Helpers
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: configureCollectionViewLayout())
        collectionView.backgroundColor = .white
        
        collectionView.register(BadgeCell.self,
                                forCellWithReuseIdentifier: BadgeCell.identifer)
        configureDataSource()
    }
    
    private func configureCollectionViewLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (_, _) -> NSCollectionLayoutSection? in
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
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
    }
    
    private func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView,
                                cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: BadgeCell.identifer,
                for: indexPath) as? BadgeCell else {
                return BadgeCell()
            }
            cell.bind(badge: item,
                      disposeBag: self.disposeBag)
            return cell
        })
    }
    
    private func configureUI() {
        configureNavigationBar()
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func configureNavigationBar() {
        title = "대표 캐릭터"
        navigationController?.navigationBar.backgroundColor = .white
        let finishButton = UIBarButtonItem(title: "완료",
                                           style: .done,
                                           target: self,
                                           action: #selector(finishButtonDidTap))
        let cancelButton = UIBarButtonItem(title: "취소",
                                           style: .plain,
                                           target: self,
                                           action: #selector(cancelButtonDidTap))
        navigationItem.rightBarButtonItem = finishButton
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    @objc private func finishButtonDidTap() {
        finishButtonTapped.onNext(())
    }
    
    @objc private func cancelButtonDidTap() {
        cancelButtonTapped.onNext(())
    }
}

extension CharacterSelectViewController {
    // MARK: - Bind
    private func bind() {
        let input = CharacterSelectViewModel.Input(viewWillAppearEvent: rx.viewWillAppear.asObservable(),
                                                   selectedCharacterIndex: collectionView.rx.itemSelected.asObservable(),
                                                   finishButtonTapped: finishButtonTapped,
                                                   cancelButtonTapped: cancelButtonTapped)
        let output = viewModel.transform(input: input)
        
        output.ownedBadges
            .subscribe(onNext: { [weak self] badges in
                guard let self else { return }
                self.makeSnapshot(badges: badges)
            }).disposed(by: disposeBag)
    }
    
    private func makeSnapshot(badges: [Badge]) {
        guard let dataSource else { return }
        var snapshot = dataSource.snapshot()
        snapshot.appendSections([.badges])
        snapshot.appendItems(badges, toSection: .badges)
        dataSource.apply(snapshot)
    }
}
