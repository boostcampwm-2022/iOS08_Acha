//
//  MultiGameRoomViewController.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

final class MultiGameRoomViewController: UIViewController {
    
    private lazy var qrCodeImageView = UIImageView()
    private lazy var roomIdLabel: UILabel = UILabel().then {
        $0.font = .largeBody
        $0.textColor = .pointDark
        $0.textAlignment = .center
    }
    private lazy var roomCollectionView = UICollectionView(
        frame: CGRect.zero,
        collectionViewLayout: UICollectionViewFlowLayout.init()
    )
    private lazy var startButton: UIButton = UIButton().then {
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .pointLight
        $0.setTitle("시작하기", for: .normal)
    }

    private let viewModel: MultiGameRoomViewModel
    
    enum Section {
        case gameRoom
    }
    
    typealias RoomDataSource = UICollectionViewDiffableDataSource<Section, RoomUser>
    typealias RoomSnapShot = NSDiffableDataSourceSnapshot<Section, RoomUser>
    
    private lazy var dataSource = makeDataSource()
    
    init(viewModel: MultiGameRoomViewModel, roomID: String) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.qrCodeImageView.image = roomID.generateQRCode()
        self.roomIdLabel.text = roomID
        view.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        bind()
        applySnapshot(datas: [.init(id: "waeatw", nickName: "내맘")])
    }
    
    func bind() {
        let inputs = MultiGameRoomViewModel.Input(
            viewWillAppear: rx.viewWillAppear.asObservable(),
            viewDidAppear: rx.viewDidAppear.asObservable()
        )
        
        _ = viewModel.transform(input: inputs)
            
    }
}
extension MultiGameRoomViewController {
    private func registerCollectionView() {
        roomCollectionView.register(
            GameRoomCollectionViewCell.self,
            forCellWithReuseIdentifier: GameRoomCollectionViewCell.identifier
        )
    }
    private func makeDataSource() -> RoomDataSource {
        let dataSource = RoomDataSource(
            collectionView: roomCollectionView
        ) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: GameRoomCollectionViewCell.identifier,
                for: indexPath
            ) as? GameRoomCollectionViewCell
            cell?.bind(data: itemIdentifier)
            return cell
        }
        return dataSource
    }
    private func applySnapshot(datas: [RoomUser]) {
        var snapshot = RoomSnapShot()
        snapshot.appendSections([.gameRoom])
        snapshot.appendItems(datas)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension MultiGameRoomViewController {
    private func layout() {
        addViews()
        addConstraints()
        configureCollectionView()
    }
    
    private func addViews() {
        view.addSubview(qrCodeImageView)
        view.addSubview(roomIdLabel)
        view.addSubview(roomCollectionView)
        view.addSubview(startButton)
    }
    
    private func addConstraints() {
        qrCodeImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(50)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(100)
            $0.height.equalTo(200)
        }
        
        roomIdLabel.snp.makeConstraints {
            $0.top.equalTo(qrCodeImageView.snp.bottom).inset(-50)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        startButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.bottom.equalToSuperview().inset(40)
        }
    }
    
    private func makeCompositionLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(0.8)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(40)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func configureCollectionView() {
        roomCollectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: makeCompositionLayout()
        )
        registerCollectionView()
        roomCollectionView.backgroundColor = .green
        view.addSubview(roomCollectionView)
        roomCollectionView.snp.makeConstraints {
            $0.top.equalTo(roomIdLabel.snp.bottom).inset(-40)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(100)
        }
    }
}
