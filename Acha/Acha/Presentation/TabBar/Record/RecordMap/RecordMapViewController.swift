//
//  RecordMapViewController.swift
//  Acha
//
//  Created by 배남석 on 2022/11/22.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

enum RecordMapViewSections: Hashable {
    case category
    case ranking(String)
    
    var title: String {
        switch self {
        case .category:
            return "category"
        case .ranking(let mapName):
            return mapName
        }
    }
}

enum RecordMapViewItems: Hashable {
    case category
    case ranking
}

class RecordMapViewController: UIViewController {
    // MARK: - UI properties
    private var collectionView: UICollectionView!
    
    // MARK: - Properties
    typealias DataSource = UICollectionViewDiffableDataSource<RecordMapViewSections, RecordMapViewItems>
    private var dataSource: DataSource!
    private let viewModel: RecordMapViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycles
    init(viewModel: RecordMapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Helpers
    
    

}
