//
//  BadgeViewController.swift
//  Acha
//
//  Created by 조승기 on 2022/11/30.
//

import UIKit
import Then
import SnapKit

struct Badge {
    let id: Int
    let name: String
    let image: String
    let isHidden: String
}

class BadgeViewController: UIViewController {
    // MARK: - UI properties
    private var collectionView: UICollectionView!
    // MARK: - Properties
    let viewModel: BadgeViewModel
    
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
    }
    
    private func cofigureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
        
        collectionView.dataSource = self
        collectionView.register(BadgeCell.self, forCellWithReuseIdentifier: BadgeCell.identifer)
        collectionView.register(MyPageHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: MyPageHeaderView.identifer)
        collectionView.backgroundColor = .white
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func configureCollectionViewLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] (sectionIndex: Int, _ ) -> NSCollectionLayoutSection? in
            guard let self else { return }
            let itemSize = NSCollectionLayoutSize(widthDimension: 1.0,
                                                  heightDimension: 1.0)
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: 0.3,
                                                   heightDimension: .absolute(120))
            let groupInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.contentInsets = groupInsets
            
            let headerSize = NSCollectionLayoutSize(widthDimension: 1.0, heightDimension: .absolute(50))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                     elementKind: UICollectionView.elementKindSectionHeader,
                                                                     alignment: .top)
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [header]
            return section
        }
    }
}

extension BadgeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        3
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BadgeCell.identifer, for: indexPath)
                as? BadgeCell else { return UICollectionViewCell() }
    }
}
