//
//  CommunityDetailViewController.swift
//  Acha
//
//  Created by hong on 2022/11/29.
//

import UIKit
import RxSwift
import RxRelay

final class CommunityDetailViewController: UIViewController, UICollectionViewDelegate {
    enum Section {
        case post
        case comment
    }
     
    enum Item: Hashable {
        case post(Post)
        case comment(Comment)
    }
    
    // MARK: - UI properties
    private var collectionView: UICollectionView!
    private lazy var commentView = CommentView()
    
    // MARK: - Properties
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    private var dataSource: DataSource!
    private let viewModel: CommunityDetailViewModel
    private let disposeBag = DisposeBag()
    
    var postCellModifyButtonTapEvent = PublishRelay<Void>()
    var postCellDeleteButtonTapEvent = PublishRelay<Void>()
    
    // MARK: - Lifecycles
    init(viewModel: CommunityDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bind()
    }
    
    // MARK: - Helpers
    private func bind() {
        let input = CommunityDetailViewModel.Input(
            viewWillAppearEvent: rx.methodInvoked(#selector(viewWillAppear(_:)))
                .map { _ in }
                .asObservable(),
            commentRegisterButtonTapEvent: commentView
                .commentButton
                .rx.tap
                .map { [weak self] _ in
                    guard let self else { fatalError() }
                    self.commentView.commentTextView.text = ""
                    
                    return Comment(userId: "USER1",
                            nickName: "USER1",
                            text: self.commentView.commentTextView.text)
                }
                .asObservable(),
            postModifyButtonTapEvent: postCellModifyButtonTapEvent.asObservable(),
            postDeleteButtonTapEvent: postCellDeleteButtonTapEvent.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.post
            .subscribe(onNext: { [weak self] post in
                guard let self else { return }
                self.makeSnapshot(post: post)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .pointLight
        navigationItem.title = "게시글"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.pointLight]
        
        KeyboardManager.keyboardWillHide(view: commentView, superView: view)
        KeyboardManager.keyboardWillShow(view: commentView, superView: view)
        hideKeyboardWhenTapped()
    
        view.addSubview(commentView)
        
        commentView.snp.makeConstraints {
            $0.trailing.leading.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(100)
        }
        
        configureCollectionView()
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: collectionViewLayout())
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        
        collectionView.register(CommunityDetailPostCell.self,
                                forCellWithReuseIdentifier: CommunityDetailPostCell.identifier)
        collectionView.register(CommunityDetailCommentCell.self,
                                forCellWithReuseIdentifier: CommunityDetailCommentCell.identifier)
        collectionView.register(CommunityDetailCommentHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: CommunityDetailCommentHeaderView.identifier)
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(15)
            $0.bottom.equalTo(commentView.snp.top)
        }
        
        configureDataSource()
    }
    
    private func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView,
                                cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
            guard let self else { return UICollectionViewCell() }
            
            print(indexPath, itemIdentifier)
            
            switch itemIdentifier {
            case .post(let post):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CommunityDetailPostCell.identifier,
                    for: indexPath) as? CommunityDetailPostCell
                else { return UICollectionViewCell() }
                
                cell.bind(post: post)
                cell.modifyButtonTapEvent
                    .asObservable()
                    .debug()
                    .bind(to: self.postCellModifyButtonTapEvent)
                    .disposed(by: self.disposeBag)
//                cell.deleteButtonTapEvent
//                    .subscribe(onNext: { _ in
//                        self.postCellDeleteButtonTapEvent.accept(())
//                    }).disposed(by: self.disposeBag)
                
                return cell
            case .comment(let comment):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CommunityDetailCommentCell.identifier,
                    for: indexPath) as? CommunityDetailCommentCell
                else { return UICollectionViewCell() }
                print("아무거나")
                cell.bind(comment: comment)
                
                return cell
            }
        })
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: CommunityDetailCommentHeaderView.identifier,
                    for: indexPath) as? CommunityDetailCommentHeaderView
                else { return UICollectionReusableView() }
                return header
            }
            return UICollectionReusableView()
        }
    }
    
    private func collectionViewLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex: Int, _ )
            -> NSCollectionLayoutSection? in
            guard let self else { fatalError() }
            switch sectionIndex {
            case 0:
                return self.postLayout()
            default:
                return self.commentLayout()
            }
        }
        
        return layout
    }
    
    private func commentLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(50)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(50)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(70))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    private func postLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(114)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(114)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    private func makeSnapshot(post: Post) {
        var snapshot = dataSource.snapshot()
//        snapshot.deleteSections([.post, .comment])
        
        snapshot.appendSections([.post, .comment])
        snapshot.appendItems([.post(post)], toSection: .post)
        
        guard let comments = post.comments else {
//            dataSource.apply(snapshot)
            return
        }
        comments.forEach {
            snapshot.appendItems([.comment($0)], toSection: .comment)
        }
        
        dataSource.apply(snapshot)
    }
}

extension CommunityDetailViewController {
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
