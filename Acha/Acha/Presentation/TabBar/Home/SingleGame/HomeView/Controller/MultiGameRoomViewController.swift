//
//  MultiGameRoomViewController.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import UIKit
import Then
import SnapKit

final class MultiGameRoomViewController: UIViewController {
    
    lazy var qrCodeImageView = UIImageView()
    private let viewModel: MultiGameRoomViewModel
    
    enum Section {
        case gameRoom
    }
    
    typealias RoomDataSource = NSDiffableDataSourceSnapshot<Section, RoomUser>
    typealias RoomSnapShot = NSDiffableDataSourceSnapshot<Section, RoomUser>
    
    init(viewModel: MultiGameRoomViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
    }
}

extension MultiGameRoomViewController {
    private func layout() {
        addViews()
        addConstraints()
    }
    
    private func addViews() {
        view.addSubview(qrCodeImageView)
    }
    
    private func addConstraints() {
        qrCodeImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(50)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(100)
            $0.height.equalTo(200)
        }
    }
}

struct RoomUser: Hashable {
    let id: String
    let nickName: String
}
