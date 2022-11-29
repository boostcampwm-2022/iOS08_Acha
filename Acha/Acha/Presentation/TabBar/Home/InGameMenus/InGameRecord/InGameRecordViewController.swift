//
//  GameRecordViewController.swift
//  Acha
//
//  Created by hong on 2022/11/15.
//

import UIKit
import RxSwift

final class InGameRecordViewController: InGamePlayMenuViewController {

    // MARK: - UI properties
    // MARK: - Properties
    enum Section {
        case main
    }
    
    private let viewModel: InGameRecordViewModel
    private let disposeBag = DisposeBag()
    private lazy var recordDataSource: RecordDataSource = configureDataSource()
    
    typealias RecordDataSource = UICollectionViewDiffableDataSource<Section, InGameRecord>
    typealias RecordSnapShot = NSDiffableDataSourceSnapshot<Section, InGameRecord>
    
    // MARK: - Lifecycles
    init(viewModel: InGameRecordViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "기록"
        bind()
        collectionViewRegister()
    }
    
    // MARK: - Helpers
    private func bind() {
        let input = InGameRecordViewModel.Input()
        let output = viewModel.transform(input: input)
        output.inGameRecord
            .subscribe(onSuccess: { [weak self] in
                guard let self else { return }
                self.makeSnapshot(data: $0)
            }).disposed(by: disposeBag)

    }
    private func collectionViewRegister() {
        collectionView.register(
            InGameMenuCollectionViewCell.self,
            forCellWithReuseIdentifier: InGameMenuCollectionViewCell.identifier
        )
    }
    
    private func configureDataSource() -> RecordDataSource {

        let datasource = RecordDataSource(
            collectionView: collectionView
        ) { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: InGameMenuCollectionViewCell.identifier,
                for: indexPath
            ) as? InGameMenuCollectionViewCell else {return UICollectionViewCell()}
            #warning("데이터 어떻게 보내줘야 할지 결정해야 함")
            cell.setData(
                image: nil,
                text: "\(itemIdentifier.date.convertToStringFormat(format: "yyyy년 MM월 dd일 EEE요일")) \(itemIdentifier.time.convertToDayHourMinueFormat())"
            )
            return cell
        }
        return datasource
    }
    
    func makeSnapshot(data: [InGameRecord]) {
        var snapshot = RecordSnapShot()
        snapshot.appendSections([.main])
        snapshot.appendItems(data)
        recordDataSource.apply(snapshot, animatingDifferences: true)
    }
    
}

// FIXME: 이 아이도 글로벌하게 사용되는지 내부에서만 사용되는지에 따라서 스코프 안에 선언할지 별도로 파일을 만들지 룰을 만들어주세요
struct InGameRecord: Hashable, InGameMenuModelProtocol {
    var id: Int
    var time: Int
    var userName: String
    var date: Date
}
