//
//  SingGamePlayRankingView.swift
//  Acha
//
//  Created by hong on 2022/11/15.
//

import UIKit
import SnapKit
import Then

class GamePlayMenuView: UIViewController {

    // MARK: - UI properties
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createBasicListLayout())
    
    private let titleLabel =  UILabel().then {
        $0.font = FontConstants.titleFont
        $0.textColor = ColorConstants.backgroundColor
        $0.backgroundColor = ColorConstants.pointColor
        $0.textAlignment = .center
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Properties
    enum MenuType {
        case ranking
        case recordHistory
        
        var description: String {
            switch self {
            case .ranking:
                return "랭킹"
            case .recordHistory:
                return "기록"
            }
        }
    }
    let type: MenuType
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
    }
    
    init(type: MenuType) {
        self.type = type
        titleLabel.text = type.description
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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

// MARK: - Helpers
extension GamePlayMenuView {
    private func layout() {
        addViews()
        layoutViews()
    }
    
    private func addViews() {
        view.addSubview(titleLabel)
        view.addSubview(collectionView)
    }
    
    private func layoutViews() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(100)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.bottom.equalTo(view.snp.bottom)
        }
    }
}
