//
//  TexCountView.swift
//  Acha
//
//  Created by hong on 2022/11/29.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

final class TextCountView: UIView {

    private lazy var textView = UITextView().then {
        $0.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        $0.font = .subBody
    }
    
    private lazy var textCountLabel = UILabel().then {
        $0.font = .subBody
        $0.textColor = .gray
        $0.textAlignment = .right
        $0.text = "0 / 300"
    }
    
    private let disposebag = DisposeBag()

    init() {
        super.init(frame: .zero)
        layout()
        textFieldBind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func textFieldBind() {
        textView.rx.text
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] text in
                self?.textViewAdjust(texts: text)
                self?.textCountLabel.text = "\(text.count) / 300"
            })
            .disposed(by: disposebag)
    }
    
    private func textViewAdjust(texts: String) {
        var texts = texts
        if texts.count > 300 {
            texts.removeLast()
            textView.text = texts
        }
    }
    
}

extension TextCountView {
    private func layout() {
        layer.cornerRadius = 10
        layer.borderColor = UIColor.pointDark.cgColor
        layer.borderWidth = 2
        setupViews()
        addConstraints()
    }
    
    private func setupViews() {
        addSubview(textView)
        addSubview(textCountLabel)
    }
    
    private func addConstraints() {
        textView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(40)
        }
        
        textCountLabel.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview().inset(10)
            $0.height.equalTo(30)
            $0.width.equalTo(90)
        }
    }
    
}
