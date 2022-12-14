//
//  RecordMapImageCell.swift
//  Acha
//
//  Created by 배남석 on 2022/12/13.
//

import UIKit

final class RecordMapImageCell: UICollectionViewCell {
    private lazy var imageView: UIImageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    
    static let identifier: String = "RecordMapImageCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        contentView.addSubview(imageView)
    }
    
    func configureUI() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind(data: Data) {
        imageView.image = UIImage(data: data)
    }
}
