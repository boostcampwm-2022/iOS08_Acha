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

    lazy var commentTextView: UITextView = UITextView().then {
        $0.layer.borderColor = UIColor.pointLight.cgColor
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 5 
        $0.layer.backgroundColor = UIColor.white.cgColor
        $0.font = .postBody
        $0.text = textViewPlaceHolder
        $0.delegate = self
        $0.textColor = .lightGray
        $0.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    lazy var commentButton: UIButton = UIButton().then {
        $0.titleLabel?.font = .boldBody
        $0.setTitle("작성", for: .normal)
        $0.backgroundColor = .pointLight
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 5
        $0.isValid = false
    }
    
    private let disposebag = DisposeBag()
    private var textViewPlaceHolder = "텍스트를 입력해주세요."
    private let maxTextCount = 100
    
    init() {
        super.init(frame: .zero)
        setupViews()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(commentTextView)
        addSubview(commentButton)
    }
    
    private func configureUI() {
        backgroundColor = .clear
        
        commentButton.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.height.width.equalTo(60)
        }
        
        commentTextView.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
            $0.trailing.equalTo(commentButton.snp.leading).offset(-10)
        }
    }
}

extension CommentView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == textViewPlaceHolder {
           textView.text = nil
           textView.textColor = .black
       }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = .lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = textView.text.count - range.length + text.count
        if newLength > maxTextCount {
          return false
        }
        
        commentButton.isValid = newLength != 0
        
        return true
    }
}
