//
//  CommentView.swift
//  Acha
//
//  Created by hong on 2022/11/30.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class CommentView: UIView {

    lazy var commentTextView = UITextView().then {
        $0.isSelectable = true
        $0.layer.borderColor = UIColor.pointLight.cgColor
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 5 
        $0.layer.backgroundColor = UIColor.white.cgColor
        $0.font = .postBody
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    lazy var commentButton = UIButton().then {
        $0.titleLabel?.font = .boldBody
        $0.setTitle("작성", for: .normal)
        $0.backgroundColor = .pointLight
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 5
    }
    
    private let disposebag = DisposeBag()
    
    init() {
        super.init(frame: .zero)
        setupViews()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func textViewBind() {
        commentTextView.rx.text
            .compactMap { $0 }
            .subscribe { [weak self] text in
                self?.textLimit(texts: text)
            }
            .disposed(by: disposebag)
    }
    
    private func textLimit(texts: String) {
        if texts.count > 100 {
            var texts = texts
            texts.removeLast()
            commentTextView.text = texts
        }
    }
    
    private func setupViews() {
        addSubview(commentTextView)
        addSubview(commentButton)
    }
    
    private func configureUI() {
        backgroundColor = .clear
        
        commentButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-10)
            $0.height.width.equalTo(60)
        }
        
        commentTextView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview().inset(10)
            $0.trailing.equalTo(commentButton.snp.leading).offset(-10)
        }
    }
}
