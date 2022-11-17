//
//  SingGamePlayRankingView.swift
//  Acha
//
//  Created by hong on 2022/11/15.
//

import UIKit
import SnapKit
import Then

class InGamePlayMenuViewController: UIViewController {

    // MARK: - UI properties
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createBasicListLayout())
    
    let titleLabel = UILabel().then {
        $0.font = FontConstants.titleFont
        $0.textColor = .white
        $0.backgroundColor = .pointLight
        $0.textAlignment = .center
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Properties
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
    }
    
    // MARK: - Helpers
    private func createBasicListLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitems: [item])
      
        let section = NSCollectionLayoutSection(group: group)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
}

extension InGamePlayMenuViewController {
    private func layout() {
        addViews()
        layoutViews()
    }
    
    private func addViews() {
        view.addSubview(titleLabel)
        view.addSubview(collectionView)
    }
    
    private func layoutViews() {
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)

        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
