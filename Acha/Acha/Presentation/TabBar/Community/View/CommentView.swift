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
        $0.layer.cornerRadius = 5
        $0.font = .postBody
        $0.textContainerInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    lazy var commentButton = UIButton().then {
        $0.titleLabel?.font = .boldBody
        $0.setTitle("작성", for: .normal)
        $0.backgroundColor = .pointDark
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 5
    }
    
    private let disposebag = DisposeBag()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .commentBoxColor
        layout()
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
    
}

extension CommentView {
    private func layout() {
        addViews()
        addConstraints()
    }
    
    private func addViews() {
        addSubview(commentTextView)
        addSubview(commentButton)
    }
    
    private func addConstraints() {
        commentButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(60)
            $0.height.equalTo(60)
        }
        
        commentTextView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.top.bottom.equalToSuperview().inset(10)
            $0.trailing.equalTo(commentButton.snp.leading).inset(-10)
        }
    }
}
