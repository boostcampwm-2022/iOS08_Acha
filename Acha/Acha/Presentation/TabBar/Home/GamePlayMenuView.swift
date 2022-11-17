//
//  SingGamePlayRankingView.swift
//  Acha
//
//  Created by hong on 2022/11/15.
//

import UIKit

class GamePlayMenuViewController: UIViewController {

    // MARK: - UI properties
//    let collectionView = UICollectionView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontConstants.titleFont
        label.textColor = ColorConstants.backgroundColor
        label.backgroundColor = ColorConstants.pointColor
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
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
    
}

// MARK: - Helpers
extension GamePlayMenuViewController {
    private func layout() {
        addViews()
        layoutViews()
    }
    
    private func addViews() {
        view.addSubview(titleLabel)
//        view.addSubview(collectionView)
    }
    
    private func layoutViews() {
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 100)
            
//            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
//            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
