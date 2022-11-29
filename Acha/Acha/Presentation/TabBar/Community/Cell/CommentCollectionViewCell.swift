//
//  CommentCollectionViewCell.swift
//  Acha
//
//  Created by hong on 2022/11/29.
//

import UIKit

final class CommentCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "CommentCollectionViewCell"

    private lazy var nickNameLabel = UILabel().then {
        $0.font = .boldBody
        $0.textAlignment = .center
        $0.textColor = .black
    }
    
    private lazy var timeLabel = UILabel().then {
        $0.font = .smallTitle
        $0.textColor = .black
    }
    
    private lazy var contextLabel = UILabel().then {
        $0.font = .body
    }
    
}
