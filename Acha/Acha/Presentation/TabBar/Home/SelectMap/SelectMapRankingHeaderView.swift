//
//  SelectMapRankingHeaderView.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/22.
//

import UIKit
import Then
import SnapKit

final class SelectMapRankingHeaderView: UICollectionReusableView {
    // MARK: - UI properties
    private let titleLabel: UILabel = UILabel().then {
            $0.font = .boldBody
            $0.textColor = .white
            $0.text = "땅 이름 랭킹"
            $0.clipsToBounds = true
        }
    
    private let closeButton: UIButton = UIButton().then {
        $0.setImage(SystemImageNameSpace.xmark.uiImage, for: .normal)
        $0.tintColor = .white
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 24)
        $0.setPreferredSymbolConfiguration(imageConfig, forImageIn: .normal)
    }
    
    // MARK: - Properties
    static let identifier = "SelectMapRankingHeaderView"
    private var closeButtonHandler: (() -> Void)?
    
    // MARK: - Lifecycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        closeButton.addTarget(self,
                              action: #selector(closeButtonDidClick),
                              for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    @objc func closeButtonDidClick() {
        closeButtonHandler?()
    }
    
    private func configureUI() {
        backgroundColor = .pointLight
        
        addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.top.trailing.bottom.equalToSuperview().inset(15)
            $0.width.height.equalTo(30)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview().inset(15)
            $0.trailing.equalTo(closeButton.snp.leading).inset(15)
        }
    }
    
    func setData(mapName: String, closeButtonHandler: (() -> Void)?) {
        titleLabel.text = mapName + " 랭킹"
        self.closeButtonHandler = closeButtonHandler
    }
}
