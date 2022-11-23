//
//  RecordMapHeaderView.swift
//  Acha
//
//  Created by 배남석 on 2022/11/22.
//

import UIKit
import RxSwift
import RxRelay

class RecordMapHeaderView: UICollectionReusableView {
    // MARK: - UI properties
    private lazy var contentView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private lazy var mapName = UILabel().then {
        $0.textColor = .pointLight
        $0.font = .largeTitle
        $0.textAlignment = .right
    }
    
    private lazy var downButton = UIButton().then {
        $0.tintColor = .pointLight
        $0.setImage(SystemImageNameSpace.chevronDown.uiImage, for: .normal)
    }
    
    // MARK: - Properties
    static let identifier = "RecordMapHeaderView"
    var parentViewController: RecordMapViewController!
    
    // MARK: - Lifecycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSubviews()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func setUpSubviews() {
        [mapName, downButton].forEach {
            addSubview($0)
        }
    }
    
    private func configureUI() {
        mapName.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.greaterThanOrEqualTo(30)
        }
        
        downButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalTo(mapName.snp.trailing).offset(5)
            $0.width.greaterThanOrEqualTo(30)
        }
    }
    
    func setMapName(mapName: String) {
        self.mapName.text = mapName
    }
    
    func setDropDownMenus(maps: [Map]) {
        var menuItems: [UIAction] = []
        maps.forEach {
            menuItems.append(
                UIAction(title: $0.name) { action in
                    self.parentViewController.makeSnapshot()
                    self.parentViewController.appendRankingSectionAndItems(mapName: action.title)
            })
        }
        downButton.menu = UIMenu(children: menuItems)
        downButton.showsMenuAsPrimaryAction = true
    }
    
    func getMapName() -> String {
        guard let text = mapName.text else { return ""}
        
        return text
    }
}
