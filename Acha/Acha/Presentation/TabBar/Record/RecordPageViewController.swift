//
//  RecordPageViewController.swift
//  Acha
//
//  Created by 배남석 on 2022/11/22.
//

import UIKit

class RecordPageViewController: UIViewController {
    // MARK: - UI properties
    private lazy var pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                               navigationOrientation: .horizontal)
    private let recordMainViewController: RecordMainViewController
    private let recordMapViewController: RecordMapViewController
    private lazy var viewList = [recordMainViewController, recordMapViewController]
    
    // MARK: - Lifecycles
    init(recordMainViewController: RecordMainViewController,
         recordMapViewController: RecordMapViewController) {
        self.recordMainViewController = recordMainViewController
        self.recordMapViewController = recordMapViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        configureUI()
    }
    
    // MARK: - Helpers
    private func setUpViews() {
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.view.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        if let firstVC = viewList.first {
            pageViewController.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
    }
    
    private func configureUI() {
        navigationItem.title = "개인 기록"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.pointLight]
    }
}

extension RecordPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = viewList.firstIndex(of: viewController) else {return nil}
        
        if viewList[index] is RecordMapViewController {
            navigationItem.title = "맵 랭킹"
        } else if viewList[index] is RecordMainViewController {
            navigationItem.title = "개인 기록"
        }
        
        let previousIndex = index - 1
        if previousIndex < 0 { return nil}
        
        return viewList[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = viewList.firstIndex(of: viewController) else {return nil}

        if viewList[index] is RecordMapViewController {
            navigationItem.title = "맵 랭킹"
        } else if viewList[index] is RecordMainViewController {
            navigationItem.title = "개인 기록"
        }
        
       let nextIndex = index + 1
       if nextIndex == viewList.count { return nil}
        
       return viewList[nextIndex]
    }
}
