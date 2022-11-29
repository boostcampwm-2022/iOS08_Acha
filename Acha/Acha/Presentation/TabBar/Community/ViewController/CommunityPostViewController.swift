//
//  CommunityPostViewController.swift
//  Acha
//
//  Created by hong on 2022/11/29.
//

import UIKit
import Then
import SnapKit

final class CommunityPostViewController: UIViewController {
    
    let scrollView = UIScrollView()
    let contentView = UIStackView()
    
    private let postWriteTextView = TextCountView()
    private let postWriteView = UIView()

    private let imageButtonView = UIView()
    
    private let imageAddButton = UIButton().then {
        $0.backgroundColor = .green
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        layout()
        title = "글 작성"
    }

}

extension CommunityPostViewController {
    private func layout() {
        configureContentView()
        configureRightBarItem()
        addViews()
        addConstraints()
    }
    
    private func addViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addArrangedSubview(postWriteView)
        postWriteView.addSubview(postWriteTextView)
        contentView.addArrangedSubview(imageButtonView)
        imageButtonView.addSubview(imageAddButton)
    }
    
    private func addConstraints() {
        
        scrollView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }

        contentView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.centerX.top.bottom.equalToSuperview()
        }
        
        postWriteView.snp.makeConstraints {
            $0.height.equalTo(400)
        }
        
        postWriteTextView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
        }
        
        imageButtonView.snp.makeConstraints {
            $0.width.equalTo(363)
            $0.height.equalTo(363)
        }
        
        imageAddButton.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
        }
    }
    
    private func configureContentView() {
        contentView.axis = .vertical
        contentView.spacing = 30
        contentView.distribution = .fillProportionally
    }
    
    private func configureRightBarItem() {
        let rightItem = UIBarButtonItem(title: "등록")
        navigationItem.rightBarButtonItem = rightItem
        navigationItem.rightBarButtonItem?.tintColor = .pointLight
    }
}
