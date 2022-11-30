//
//  CommunityPostViewController.swift
//  Acha
//
//  Created by hong on 2022/11/29.
//

import UIKit
import Then
import SnapKit
import PhotosUI
import RxSwift
import RxCocoa

final class CommunityPostViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIStackView()
    
    private let postWriteTextView = TextCountView()
    private let postWriteView = UIView()

    private let imageButtonView = UIView()
    
    private let imageAddButton = UIButton().then {
//        $0.setImage(.defaultSelectImage, for: .normal)
        $0.setImage(UIImage(systemName: "house"), for: .normal)
    }
    
    private let imagePicker: PHPickerViewController
    private let imageObserver = PublishSubject<Data>()
    
    private let disposeBag = DisposeBag()
    
    init() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .any(of: [.images])
        imagePicker = PHPickerViewController(configuration: configuration)
        super.init(nibName: nil, bundle: nil)
        imagePicker.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        layout()
        title = "글 작성"
        bindKeyboard()
        bindImageButton()
        bind()
    }
    
    private func bindKeyboard() {
        KeyboardManager.keyboardWillShow(view: contentView)
        KeyboardManager.keyboardWillHide(view: contentView)
        hideKeyboardWhenTapped()
    }
    
    private func bindImageButton() {
        imageAddButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                self.present(self.imagePicker, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func bind() {
        imageObserver
            .subscribe { data in
                print(data)
            }
            .disposed(by: disposeBag)
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

extension CommunityPostViewController {
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

extension CommunityPostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let itemProvider = results.first?.itemProvider
        
        if let itemProvider = itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                guard error == nil else { return }
                DispatchQueue.main.async {
                    let image = image as? UIImage
                    guard let imageData = image?.jpegData(compressionQuality: 0.5) as? Data else {return}
                    self?.imageObserver.onNext(imageData)
                    self?.imageAddButton.setImage(image, for: .normal)
                }
            }
        }
    }

}
