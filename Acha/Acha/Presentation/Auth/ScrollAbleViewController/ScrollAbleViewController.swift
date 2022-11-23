//
//  ScrollAbleViewController.swift
//  Acha
//
//  Created by hong on 2022/11/21.
//

import UIKit

class ScrollAbleViewController: UIViewController {
    
    let scrollView = UIScrollView()
    let contentView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        hideKeyboardWhenTapped()
    }

}

extension ScrollAbleViewController {
    func addView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
    }
    
    func addConstraint() {
        
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.centerX.top.bottom.equalToSuperview()
        }
    }
    
    func configure() {
        addView()
        addConstraint()
        contentView.axis = .vertical
        contentView.spacing = 50
        contentView.backgroundColor = .white
    }
    
}

extension ScrollAbleViewController {
    
    private func hideKeyboardWhenTapped() {
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
