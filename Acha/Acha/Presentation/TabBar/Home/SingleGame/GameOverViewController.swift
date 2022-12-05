//
//  GameOverViewController.swift
//  Acha
//
//  Created by 조승기 on 2022/11/15.
//

import UIKit
import SnapKit
import Then
import RxSwift

class GameOverViewController: UIViewController {
    // MARK: - UI properties
    private let resultBackground: UIView = UIView().then {
        $0.backgroundColor = .gray.withAlphaComponent(0.5)
        $0.layer.cornerRadius = 20
    }
    private let gameOverLabel: UILabel = UILabel().then {
        $0.text = "게임 종료"
        $0.font = .largeTitle
        $0.textAlignment = .center
    }
    private let mapNameLabel: UILabel = UILabel().then {
        $0.font = .largeBody
        $0.textAlignment = .center
    }
    private let timeLabel: UILabel = UILabel().then {
        $0.text = "시간"
        $0.font = .largeTitle
        $0.textAlignment = .left
    }
    private let timeValueLabel: UILabel = UILabel().then {
        $0.font = .body
        $0.textAlignment = .center
    }
    private let distanceLabel: UILabel = UILabel().then {
        $0.text = "거리"
        $0.font = .largeTitle
        $0.textAlignment = .left
    }
    private let distanceValueLabel: UILabel = UILabel().then {
        $0.font = .body
        $0.textAlignment = .center
    }
    private let kcalLabel: UILabel = UILabel().then {
        $0.text = "칼로리"
        $0.font = .largeTitle
        $0.textAlignment = .left
    }
    private let kcalValueLabel: UILabel = UILabel().then {
        $0.font = .body
        $0.textAlignment = .center
    }
    private let rankBoardStackView: UIStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.spacing = 13
    }
    private let okButton: UIButton = UIButton().then {
        $0.setTitle("확인", for: .normal)
        $0.tintColor = .white
        $0.backgroundColor = .lightGray
        $0.layer.cornerRadius = 10
    }
    
    // MARK: - Properties
    private let viewModel: GameOverViewModel
    // MARK: - Lifecycles
    init(viewModel: GameOverViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        tabBarController?.tabBar.isHidden = true
        setupSubviews()
        bind()
    }
    
    // MARK: - Helpers
    func setupSubviews() {
        view.addSubview(resultBackground)
        [gameOverLabel, mapNameLabel,
         timeLabel, timeValueLabel, distanceLabel, distanceValueLabel, kcalLabel, kcalValueLabel, okButton]
            .forEach {
                resultBackground.addSubview($0)
            }
        
        resultBackground.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(44)
            $0.top.equalToSuperview().offset(140)
            $0.bottom.equalToSuperview().offset(-270)
        }
        gameOverLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(35)
            $0.centerX.equalToSuperview()
        }
        mapNameLabel.snp.makeConstraints {
            $0.top.equalTo(gameOverLabel.snp.bottom).offset(22)
            $0.centerX.equalToSuperview()
        }
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(mapNameLabel.snp.bottom).offset(15)
            $0.leading.equalToSuperview().inset(22)
        }
        timeValueLabel.snp.makeConstraints {
            $0.centerY.equalTo(timeLabel)
            $0.leading.equalTo(timeLabel.snp.trailing).offset(10)
        }
        distanceLabel.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(12)
            $0.leading.equalTo(timeLabel)
        }
        distanceValueLabel.snp.makeConstraints {
            $0.centerY.equalTo(distanceLabel)
            $0.leading.equalTo(distanceLabel.snp.trailing).offset(10)
        }
        kcalLabel.snp.makeConstraints {
            $0.top.equalTo(distanceLabel.snp.bottom).offset(12)
            $0.leading.equalTo(distanceLabel)
        }
        kcalValueLabel.snp.makeConstraints {
            $0.centerY.equalTo(kcalLabel)
            $0.leading.equalTo(kcalLabel.snp.trailing).offset(10)
        }
        okButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(102)
            $0.height.equalTo(63)
            $0.bottom.equalToSuperview().offset(-32)
        }
        
    }
    
    private func bind() {
        let input = GameOverViewModel.Input(
            okButtonTapped: okButton.rx.tap.asObservable(),
            viewDidLoad: rx.methodInvoked(#selector(UIViewController.viewWillAppear)).map { _ in }
        )    
        let output = viewModel.transform(input: input)
        let record = output.record
        
        mapNameLabel.text = output.mapName
        timeValueLabel.text = "\(record.time.convertToDayHourMinueFormat())"
        distanceValueLabel.text = record.distance.convertToDecimal+"m"
        kcalValueLabel.text = record.calorie.convertToDecimal+"kcal"
    }
}
