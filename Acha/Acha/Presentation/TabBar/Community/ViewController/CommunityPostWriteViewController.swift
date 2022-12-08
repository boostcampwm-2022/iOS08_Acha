//
//  CommunityPostWriteViewController.swift
//  Acha
//
//  Created by 배남석 on 2022/12/06.
//

import UIKit
import RxSwift
import RxRelay

final class CommunityPostWriteViewController: UIViewController {
    // MARK: - UI properties
    private lazy var scrollView: UIScrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
    }
    
    private lazy var textView: UITextView = UITextView().then {
        $0.font = .postBody
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isScrollEnabled = false
        $0.returnKeyType = .done
        $0.delegate = self
        $0.textColor = .lightGray
        $0.text = textViewPlaceHolder
        $0.layer.borderColor = UIColor.pointLight.cgColor
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 5
        $0.layer.backgroundColor = UIColor.white.cgColor
    }
    
    private lazy var textCountLabel: UILabel = UILabel().then {
        $0.textColor = .gray
        $0.text = "0 / 300"
        $0.font = .subBody
    }
    
    private lazy var imageAddButton: UIButton = UIButton().then {
        $0.setImage(UIImage.plusImage, for: .normal)
        $0.imageView?.tintColor = .pointLight
        $0.layer.cornerRadius = 5
        $0.layer.borderWidth = 2
        $0.layer.borderColor = UIColor.pointLight.cgColor
        $0.clipsToBounds = true
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold)
        $0.setPreferredSymbolConfiguration(imageConfig, forImageIn: .normal)
        $0.addTarget(self, action: #selector(imageAddButtonTapped), for: .touchUpInside)
    }
    
    private lazy var imageDeleteButton: UIButton = UIButton().then {
        $0.setImage(UIImage.xImage, for: .normal)
        $0.addTarget(self, action: #selector(imageDeleteButtonTapped), for: .touchUpInside)
    }
    
    private lazy var rightButton: UIBarButtonItem = UIBarButtonItem().then {
        $0.title = "작성하기"
        $0.style = .plain
        $0.target = self
        $0.action = #selector(rightButtonTapped)
        $0.tintColor = .pointLight
        $0.setTitleTextAttributes([.font: UIFont.defaultTitle ], for: .normal)
    }
    
    let imagePicker = UIImagePickerController().then {
        $0.sourceType = .photoLibrary
    }
    
    // MARK: - Properties
    private let disposebag = DisposeBag()
    private let viewModel: CommunityPostWriteViewModel
    private var textViewPlaceHolder = "텍스트를 입력해주세요."
    private let maxTextCount = 300
    
    private var rightButtonTapEvent = PublishRelay<(Post, Image?)>()
    
    // MARK: - Lifecycles
    init(viewModel: CommunityPostWriteViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        imagePicker.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        configureUI()
        bind()
    }
    
    override var keyCommands: [UIKeyCommand]? {
        return [UIKeyCommand(input: "\r", modifierFlags: .shift, action: #selector(handleShiftEnter(command:)))]
    }
    
    // MARK: - Helpers
    private func bind() {
        textView.rx.text
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] text in
                guard let self else { return }
                self.textCountLabel.text = "\(text.count) / 300"
            }).disposed(by: disposebag)
        
        let input = CommunityPostWriteViewModel.Input(
            viewWillAppearEvent: rx.methodInvoked(#selector(viewWillAppear(_:)))
                .map { _ in}
                .asObservable(),
            rightButtonTapped: rightButtonTapEvent.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.post
            .asDriver(onErrorJustReturn: Post())
            .drive(onNext: { [weak self] post in
                guard let self else { return }
                self.textView.text = post.text
                self.textView.textColor = .black
                if let image = post.image {
                    let service = DefaultFirebaseStorageNetworkService()
                    service.download(urlString: image) { data in
                        guard let data else { return }
                        DispatchQueue.main.async { [weak self] in
                            guard let self else { return }
                            self.imageAddButton.imageView?.image = UIImage(data: data)
                        }
                    }
                }
                
            }).disposed(by: disposebag)
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(textView)
        scrollView.addSubview(textCountLabel)
        scrollView.addSubview(imageAddButton)
        scrollView.addSubview(imageDeleteButton)
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "게시글 작성"
        navigationItem.rightBarButtonItem = rightButton
        navigationController?.navigationBar.tintColor = .pointLight
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.pointLight]
        
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        textView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(15)
            $0.width.equalTo(view.frame.width - 30)
        }
        
        textCountLabel.snp.makeConstraints {
            $0.top.equalTo(textView.snp.bottom).offset(10)
            $0.trailing.equalTo(textView)
            $0.width.lessThanOrEqualTo(100)
            $0.height.lessThanOrEqualTo(50)
        }
        
        imageAddButton.snp.makeConstraints {
            $0.top.equalTo(textCountLabel.snp.bottom).offset(40)
            $0.leading.trailing.equalTo(textView)
            $0.height.equalTo(textView.snp.width)
            $0.bottom.lessThanOrEqualToSuperview()
        }
        
        imageDeleteButton.snp.makeConstraints {
            $0.centerX.equalTo(imageAddButton.snp.trailing)
            $0.centerY.equalTo(imageAddButton.snp.top)
            $0.height.width.equalTo(25)
        }
    }
    
    @objc func handleShiftEnter(command: UIKeyCommand) {
        if textView.text.count < maxTextCount {
            textView.insertText("\r")
        }
    }
    
    @objc func imageAddButtonTapped() {
        present(imagePicker, animated: false, completion: nil)
    }
    
    @objc func imageDeleteButtonTapped() {
        imageAddButton.setImage(UIImage.plusImage, for: .normal)
    }
    
    @objc private func rightButtonTapped() {
        let imageName = UUID().uuidString + String(Date().timeIntervalSince1970)
        let post = Post(userId: "유저ID",
                        nickName: "닉네임",
                        text: textView.text)
        
        if imageAddButton.imageView?.image != UIImage.plusImage {
            guard let data = imageAddButton.imageView?.image?.jpegData(compressionQuality: 0.4) else { return }
            let image = Image(name: imageName,
                              data: data)
            
            self.rightButtonTapEvent.accept((post, image))
        } else {
            self.rightButtonTapEvent.accept((post, nil))
        }
    }
}

extension CommunityPostWriteViewController: UITextViewDelegate {
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
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        let newLength = textView.text.count - range.length + text.count
        if newLength > maxTextCount {
          return false
        }
        return true
    }
}

extension CommunityPostWriteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageAddButton.setImage(image, for: .normal)
        }
        dismiss(animated: true, completion: nil)
    }
}
