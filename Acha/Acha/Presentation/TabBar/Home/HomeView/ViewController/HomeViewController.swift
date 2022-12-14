//
//  HomeViewController.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit
import Then
import SnapKit
import RxCocoa
import RxSwift

final class HomeViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    // MARK: - UI properties
    private lazy var startGameContentView = UIView().then {
        $0.layer.shadowOffset = CGSize(width: 0, height: 10)
        $0.layer.shadowColor = UIColor.gray.cgColor
        $0.layer.shadowOpacity = 1.0
        $0.layer.shadowOffset = CGSize.zero
        $0.layer.shadowRadius = 6
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .white
    }
    
    private let titleLabel = UILabel().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        let cornerMask: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.layer.maskedCorners = cornerMask
        $0.layer.backgroundColor = UIColor.pointLight.cgColor
        $0.numberOfLines = 0
        $0.font = .boldSystemFont(ofSize: 34)
        $0.textColor = .white
        $0.text = " 시작하기"
        $0.sizeToFit()
    }
    
    private lazy var singleGameShadowView = UIImageView().then {
        $0.layer.shadowOffset = CGSize(width: 0, height: 5)
        $0.layer.shadowColor = UIColor.gray.cgColor
        $0.layer.shadowOpacity = 1.0
        $0.layer.shadowOffset = CGSize.zero
        $0.layer.shadowRadius = 6
    }
    
    private lazy var singleGameImageView = UIImageView().then {
        $0.layer.cornerRadius = 10
        $0.image = UIImage(named: "map_0")
        $0.layer.masksToBounds = true
    }
    
    private lazy var multiGameShadowView = UIImageView().then {
        $0.layer.shadowOffset = CGSize(width: 0, height: 5)
        $0.layer.shadowColor = UIColor.gray.cgColor
        $0.layer.shadowOpacity = 1.0
        $0.layer.shadowOffset = CGSize.zero
        $0.layer.shadowRadius = 6
    }
    
    private lazy var multiGameImageView: UIImageView = UIImageView().then {
        $0.layer.cornerRadius = 10
        $0.image = UIImage(named: "map_1")
        $0.layer.masksToBounds = true
    }
    private lazy var startSingleGameButton = UIButton().then {
        $0.layer.backgroundColor = UIColor.pointLight.cgColor
        $0.setTitle("혼자 하기", for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 30)
        $0.tintColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.shadowOffset = CGSize(width: 0, height: 10)
        $0.layer.shadowColor = UIColor.gray.cgColor
        $0.layer.shadowOpacity = 1.0
        $0.layer.shadowOffset = CGSize.zero
        $0.layer.shadowRadius = 6
    }
    
    private lazy var startMultiGameButton = UIButton().then {
        $0.layer.backgroundColor = UIColor.pointLight.cgColor
        $0.setTitle("같이 하기", for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 30)
        $0.tintColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.shadowOffset = CGSize(width: 0, height: 10)
        $0.layer.shadowColor = UIColor.gray.cgColor
        $0.layer.shadowOpacity = 1.0
        $0.layer.shadowOffset = CGSize.zero
        $0.layer.shadowRadius = 6
    }
    private lazy var multiGameEnterView = MultiGameEnterViewController()
    private lazy var qrReaderView = QRReaderViewController()
    
    // MARK: - Properties
    private let disposeBag: DisposeBag = DisposeBag()
    let viewModel: HomeViewModel
    
    // MARK: - Lifecycles
    init(viewModel: HomeViewModel) {
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

    private func bind() {
        let inputs = HomeViewModel.Input(
            viewWillAppear: rx.viewWillAppear.asObservable(),
            singleGameModeDidTap: startSingleGameButton.rx.tap.asObservable(),
            multiGameModeDidTap: startMultiGameButton.rx.tap.asObservable(),
            makeRoomButtonDidTap: multiGameEnterView.makeRoomButton.rx.tap.asObservable(),
            enterOtherRoomButtonDidTap: multiGameEnterView.enterRoomtButton.rx.tap.asObservable(),
            cameraDetectedSometing: qrReaderView.roomIDInformation.asObservable()
        )
        
        let outputs = viewModel.transform(input: inputs)
        outputs.multiGameModeTapped
            .subscribe { [weak self] _ in
                guard let strongSelf = self else {return}
                strongSelf.present(strongSelf.multiGameEnterView, animated: true)
            }
            .disposed(by: disposeBag)

        outputs.roomEnterBehavior
            .subscribe { [weak self] _ in
                guard let strongSelf = self else {return}
                strongSelf.multiGameEnterView.dismiss(animated: true)
                strongSelf.present(strongSelf.qrReaderView, animated: true)
            }
            .disposed(by: disposeBag)
        
        outputs.uuidDidPass
            .subscribe { [weak self] _ in
                self?.multiGameEnterView.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        configureNavigationBar()
        
        view.addSubview(startGameContentView)
        view.addSubview(titleLabel)
        startGameContentView.addSubview(singleGameShadowView)
        singleGameShadowView.addSubview(singleGameImageView)
        startGameContentView.addSubview(startSingleGameButton)
        startGameContentView.addSubview(multiGameShadowView)
        multiGameShadowView.addSubview(multiGameImageView)
        startGameContentView.addSubview(startMultiGameButton)

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.height.equalTo(80)
        }
        
        startGameContentView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(titleLabel)
            $0.height.equalTo(380)
        }
        
        singleGameShadowView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalTo(view.snp.centerX).offset(-5)
            $0.bottom.equalToSuperview().offset(-20)
        }
        
        singleGameImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        startSingleGameButton.snp.makeConstraints {
            $0.center.equalTo(singleGameImageView)
            $0.leading.trailing.equalTo(singleGameImageView).inset(15)
            $0.height.equalTo(100)
        }
        
        multiGameShadowView.snp.makeConstraints {
            $0.top.bottom.equalTo(singleGameShadowView)
            $0.leading.equalTo(view.snp.centerX).offset(5)
            $0.trailing.equalToSuperview().offset(-10)
        }
        
        multiGameImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        startMultiGameButton.snp.makeConstraints {
            $0.center.equalTo(multiGameImageView)
            $0.leading.trailing.equalTo(multiGameImageView).inset(15)
            $0.height.equalTo(startSingleGameButton)
        }
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.title = "땅따먹기"
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: UIColor.pointLight
        ]
        navigationController?.navigationBar.shadowImage = UIImage()
    }
}
