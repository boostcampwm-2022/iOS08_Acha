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
        case post(Post, Bool)
        case comment(Comment)
    }
    
    // MARK: - UI properties
    private lazy var collectionView = UICollectionView(frame: .zero,
                                                       collectionViewLayout: collectionViewLayout())
    private let commentView = CommentView()
    
    // MARK: - Properties
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    private var dataSource: DataSource!
    private let viewModel: CommunityDetailViewModel
    private let disposeBag = DisposeBag()
    
    var postCellModifyButtonTapEvent = PublishRelay<Post>()
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
        AchaKeyboard.shared.keyboardHeight
            .drive(onNext: { [weak self] keyboardHeight in
                guard let self = self else {return}
                if keyboardHeight != 0 {
                    self.commentView.snp.updateConstraints {
                        $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
                            .offset( self.view.safeAreaInsets.bottom-keyboardHeight)
                    }
                } else {
                    self.commentView.snp.updateConstraints {
                        $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(10)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        let input = CommunityDetailViewModel.Input(
            viewWillAppearEvent: rx.methodInvoked(#selector(viewWillAppear(_:)))
                .map { _ in }
                .asObservable(),
            commentRegisterButtonTapEvent: commentView
                .commentButton.rx.tap
                .map { [weak self] _ in
                    guard let self else { fatalError() }
                    let commnetMessage = self.commentView.commentTextView.text
                    self.commentView.commentTextView.text = ""
                    return commnetMessage ?? ""
                }
                .asObservable(),
            postModifyButtonTapEvent: postCellModifyButtonTapEvent.asObservable(),
            postDeleteButtonTapEvent: postCellDeleteButtonTapEvent.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.post
            .subscribe(onNext: { [weak self] (post, isMine) in
                guard let self else { return }
                self.makeSnapshot(post: post, isMine: isMine)
            })
            .disposed(by: disposeBag)
        
        output.commentWriteSuccess
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.reloadSnapshot()
                self.collectionView.setContentOffset(
                    CGPoint(
                        x: 0,
                        y: self.collectionView.contentSize.height - self.collectionView.bounds.height),
                    animated: true
                )
            })
            .disposed(by: disposeBag)
    }
    
    private func configureUI() {
        hideKeyboardWhenTapped()
        view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .pointLight
        navigationItem.title = "게시글"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.pointLight]
        
        view.addSubview(commentView)
        
        commentView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.height.equalTo(100)
        }
        
        configureCollectionView()
    }
    
    private func configureCollectionView() {
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
            switch itemIdentifier {
            case .post(let post, let isMine):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CommunityDetailPostCell.identifier,
                    for: indexPath) as? CommunityDetailPostCell
                else { return UICollectionViewCell() }
                
                cell.bind(post: post, isMine: isMine)
                cell.modifyButtonTapEvent?
                    .subscribe(onNext: { sendPost in
                        var newPost = sendPost
                        newPost.id = post.id
                        newPost.image = post.image
                        newPost.comments = post.comments
                        self.postCellModifyButtonTapEvent.accept(newPost)
                    })
                    .disposed(by: self.disposeBag)
                cell.deleteButtonTapEvent?
                    .subscribe(onNext: { _ in
                        self.postCellDeleteButtonTapEvent.accept(())
                    }).disposed(by: self.disposeBag)
                
                return cell
            case .comment(let comment):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CommunityDetailCommentCell.identifier,
                    for: indexPath) as? CommunityDetailCommentCell
                else { return UICollectionViewCell() }
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
            heightDimension: .estimated(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100)
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
            heightDimension: .estimated(130)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(130)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    private func makeSnapshot(post: Post, isMine: Bool) {
        var snapshot = Snapshot()
        snapshot.deleteSections([.post, .comment])
        
        snapshot.appendSections([.post, .comment])
        snapshot.appendItems([.post(post, isMine)], toSection: .post)
        
        guard let comments = post.comments else {
            dataSource.apply(snapshot)
            return
        }
        comments.forEach {
            snapshot.appendItems([.comment($0)], toSection: .comment)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func reloadSnapshot() {
        var snapshot = dataSource.snapshot()
        snapshot.reloadSections([.comment])
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
