//
//  MultiGameChatViewController.swift
//  Acha
//
//  Created by hong on 2022/12/08.
//

import UIKit
import Then
import SnapKit
import RxSwift

final class MultiGameChatViewController: UIViewController {
    
    enum Section {
        case chat
    }
    private lazy var chatCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    private lazy var commentView = CommentView()

    typealias ChatDataSource = UICollectionViewDiffableDataSource<Section, Chat>
    typealias ChatSnapShot = NSDiffableDataSourceSnapshot<Section, Chat>
    
    private lazy var chatDataSource = makeDataSource()
    private lazy var chatSnapShot = ChatSnapShot()
    
    private weak var viewModel: MultiGameChatViewModel?
    private let disposeBag = DisposeBag()
    
    init(viewModel: MultiGameChatViewModel, roomID: String) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCommentView()
        configureCollectionView()
        bind()
        keyboardBind()
    }

    private func bind() {
        let inputs = MultiGameChatViewModel.Input(
            viewDidAppear: rx.viewDidAppear.asObservable(),
            commentButtonTapped: commentView.commentButton.rx.tap.asObservable(),
            textInput: commentView.commentTextView.rx.text.orEmpty.asObservable(),
            viewWillDisappear: rx.viewWillDisappear.asObservable(),
            didEnterBackground: UIApplication.rx.didEnterBackground.asObservable()
        )
        
        guard let outputs = viewModel?.transform(input: inputs) else {return}
        
        outputs.chatFetched
            .drive(onNext: { [weak self] chats in
                self?.makeSnapShot(data: chats)
            })
            .disposed(by: disposeBag)
        
        outputs.chatDelievered
            .delay(.milliseconds(450))
            .drive(onNext: { [weak self] _ in
                self?.commentView.commentTextView.text = ""
            })
            .disposed(by: disposeBag)
    }
    
    private func keyboardBind() {
        hideKeyboardWhenTapped()
        
        AchaKeyboardManager.shared.keyboardHeight
            .drive(onNext: { [weak self] keyboardHeight in
                guard let self else {return}
                let height = keyboardHeight > 0 ? self.view.safeAreaInsets.bottom - keyboardHeight : -20
                self.commentView.snp.updateConstraints {
                    $0.bottom.equalTo(height)
                }
                self.view.layoutIfNeeded()
            })
            .disposed(by: disposeBag)
    }
    
    private func configureCommentView() {
        view.addSubview(commentView)
        commentView.commentTextView.text = nil
        commentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-20)
            $0.height.equalTo(80)
        }
    }
}

extension MultiGameChatViewController {
    private func makeDataSource() -> ChatDataSource {
        let dataSource = ChatDataSource(
            collectionView: chatCollectionView
        ) { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ChatCell.identifier,
                for: indexPath
            ) as? ChatCell else {return UICollectionViewCell()}
            cell.bind(data: itemIdentifier)
            return cell
        }
        return dataSource
    }
    
    private func makeSnapShot(data: [Chat]) {
        let oldItems = chatSnapShot.itemIdentifiers(inSection: .chat)
        chatSnapShot.deleteItems(oldItems)
        chatSnapShot.appendItems(data, toSection: .chat)
        chatDataSource.apply(chatSnapShot, animatingDifferences: true)
    }
    
    private func registerCollectionView() {
        chatCollectionView.register(
            ChatCell.self,
            forCellWithReuseIdentifier: ChatCell.identifier
        )
    }
    
    private func configureCollectionView() {
        chatCollectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCompositonLayout())
        view.addSubview(chatCollectionView)
        registerCollectionView()
        chatCollectionView.backgroundColor = .white
        chatCollectionView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(commentView.snp.top)
        }
        chatSnapShot.appendSections([.chat])
    }
    
    private func makeCompositonLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(50)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(50)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension MultiGameChatViewController {
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
