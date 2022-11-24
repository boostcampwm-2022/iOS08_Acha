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

final class HomeViewController: UIViewController {
    
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
    
    private lazy var titleLabel = UILabel().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        let cornerMask: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.layer.maskedCorners = cornerMask
        $0.layer.backgroundColor = (UIColor.pointLight ?? UIColor.red).cgColor
        $0.numberOfLines = 0
        $0.font = .boldSystemFont(ofSize: 34)
        $0.textColor = .white
        $0.text = " 시작하기"
        $0.sizeToFit()
    }
    
    private lazy var singleGameImageView = UIImageView().then {
        $0.layer.cornerRadius = 10
        $0.image = UIImage(named: "map_0")
        $0.layer.shadowOffset = CGSize(width: 0, height: 5)
        $0.layer.shadowColor = UIColor.gray.cgColor
        $0.layer.shadowOpacity = 1.0
        $0.layer.shadowOffset = CGSize.zero
        $0.layer.shadowRadius = 6
    }
    
    private lazy var multiGameImageView = UIImageView().then {
        $0.layer.cornerRadius = 10
        $0.image = UIImage(named: "map_1")
        $0.layer.shadowOffset = CGSize(width: 0, height: 5)
        $0.layer.shadowColor = UIColor.gray.cgColor
        $0.layer.shadowOpacity = 1.0
        $0.layer.shadowOffset = CGSize.zero
        $0.layer.shadowRadius = 6
    }
    private lazy var startSingleGameButton = UIButton().then {
        $0.layer.backgroundColor = UIColor(named: "PointDarkColor")?.cgColor
        $0.setTitle("혼자 하기", for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 30)
        $0.tintColor = .white
        $0.layer.cornerRadius = 10
    }
    
    private lazy var startMultiGameButton = UIButton().then {
        $0.layer.backgroundColor = UIColor(named: "PointDarkColor")?.cgColor
        $0.setTitle("같이 하기", for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 30)
        $0.tintColor = .white
        $0.layer.cornerRadius = 10
    }
    
    private lazy var multiGamePreView = MultiGameEnterViewController()
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
        setUpSubviews()
        bind()
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.title = "땅따먹기"
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: UIColor.pointLight
        ]
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func bind() {
        let inputs = HomeViewModel.Input(
            singleGameModeDidTap: startSingleGameButton.rx.tap.asObservable(),
            multiGameModeDidTap: startMultiGameButton.rx.tap.asObservable(),
            makeRoomButtonDidTap: multiGamePreView.makeRoomButton.rx.tap.asObservable(),
            enterOtherRoomButtonDidTap: multiGamePreView.enterRoomtButton.rx.tap.asObservable(),
            cameraDetectedSometing: qrReaderView.roomIDInformation.asObservable()
        )
        
        let outputs = viewModel.transform(input: inputs)
        outputs.multiGameModeTapped
            .subscribe { _ in
                self.present(self.multiGamePreView, animated: true)
            }
            .disposed(by: disposeBag)

        outputs.roomEnterBehavior
            .subscribe { _ in
                self.multiGamePreView.dismiss(animated: true)
                self.present(self.qrReaderView, animated: true)
            }
        
        outputs.uuidDidPass
            .subscribe { [weak self] _ in
                self?.multiGamePreView.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func setUpSubviews() {
        view.addSubview(startGameContentView)
        view.addSubview(titleLabel)
        
        [singleGameImageView, multiGameImageView, startSingleGameButton, startMultiGameButton].forEach {
            startGameContentView.addSubview($0)
        }
        
        startGameContentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.height.equalTo(400)
            $0.centerY.equalToSuperview().offset(-50)
        }
        
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(100)
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.centerY.equalToSuperview().offset(-200)
        }
        
        singleGameImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.top.equalToSuperview().offset(120)
            $0.bottom.equalToSuperview().offset(-20)
            $0.width.equalTo(166)
        }
        
        multiGameImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-10)
            $0.top.equalToSuperview().offset(120)
            $0.bottom.equalToSuperview().offset(-20)
            $0.width.equalTo(166)
        }
        
        startSingleGameButton.snp.makeConstraints {
            $0.center.equalTo(singleGameImageView)
            $0.leading.trailing.equalTo(singleGameImageView).inset(15)
            $0.height.equalTo(100)
        }
        
        startMultiGameButton.snp.makeConstraints {
            $0.center.equalTo(multiGameImageView)
            $0.leading.trailing.equalTo(multiGameImageView).inset(15)
            $0.height.equalTo(100)
        }
    }
}
