//
//  GameRankingViewController.swift
//  Acha
//
//  Created by hong on 2022/11/15.
//

import UIKit
import RxSwift

final class InGameRankingViewController: InGamePlayMenuViewController {
    // MARK: - UI properties
    // MARK: - Properties

    enum Section {
        case main
    }
    
    private lazy var rankingDataSource: RankingDataSource = makeDataSource()
    
    typealias RankingDataSource = UICollectionViewDiffableDataSource<Section, InGameRanking>
    typealias RankingSnapShot = NSDiffableDataSourceSnapshot<Section, InGameRanking>
    
    let viewModel: InGameRankingViewModel
    let disposeBag = DisposeBag()
    
    // MARK: - Lifecycles
    init(viewModel: InGameRankingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "랭킹"
        bind()
        collectionViewRegister()
    }
    
    private func bind() {
        let input = InGameRankingViewModel.Input()
        let output = viewModel.transform(input: input)
        output.rankings
            .subscribe(onSuccess: { [weak self] in
                guard let self else { return }
                self.makeSnapshot(data: $0)
            }, onFailure: {
                print($0)
            }).disposed(by: disposeBag)
    
    }
    // MARK: - Helpers
    private func collectionViewRegister() {
        collectionView.register(
            InGameMenuCell.self,
            forCellWithReuseIdentifier: InGameMenuCell.identifier
        )
    }
    private func makeDataSource() -> RankingDataSource {

        let datasource = RankingDataSource(
            collectionView:
                collectionView
        ) { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: InGameMenuCell.identifier,
                for: indexPath
            ) as? InGameMenuCell else {return UICollectionViewCell()}
            cell.setData(
                image: UIImage(named: "rank\(indexPath.row)"),
                text: itemIdentifier.userName+"(\(itemIdentifier.time.convertToHourMinuteSecondFormat()))"
            )
            return cell
        }
        return datasource
    }
    
    func makeSnapshot(data: [InGameRanking]) {
        var snapshot = RankingSnapShot()
        snapshot.appendSections([.main])
        snapshot.appendItems(data)
        rankingDataSource.apply(snapshot, animatingDifferences: true)
    }
}
