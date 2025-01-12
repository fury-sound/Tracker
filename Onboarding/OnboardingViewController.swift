//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Valery Zvonarev on 07.01.2025.
//

import UIKit

final class OnboardingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    let imageNames = ["onboarding1", "onboarding2"]
//    let labelText = ["Отслеживайте только \n то, что хотите", "Даже если это\n не литры воды и йога"]
    let labelText = [labelLeftText, labelRightText]
    var currentIndex = 0
    
    lazy var wowButton: UIButton = {
        let button = UIButton()
        button.setTitle(buttonText, for: .normal)
//        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(didTapWow), for: .touchUpInside)
        return button
    }()
    
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = 2
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.pageIndicatorTintColor = .ypGray
        return pageControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        let pageViewController = pageAtIndex(currentIndex)
        if let startingVC = pageViewController {
            setViewControllers([startingVC], direction: .forward, animated: true, completion: nil)
        }
        setupUI()
    }
    
    func pageAtIndex(_ index: Int) -> PageViewController? {
        if index < 0 || index >= imageNames.count { return nil }
        let vc = PageViewController()
        vc.imageName = imageNames[index]
        vc.textLabelText = labelText[index]
        currentIndex = index
        return vc
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        let viewObjects = [pageControl, wowButton]
        viewObjects.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: wowButton.topAnchor, constant: -30),
            wowButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            wowButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            wowButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -84),
            wowButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc func didTapWow() {
        switchToNaviBarVC()
    }
    
    private func switchToNaviBarVC() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid windows configuration")
            return
        }
        let mainNaviBarVC = MainTrackerViewController()
        mainNaviBarVC.modalTransitionStyle = .partialCurl
        mainNaviBarVC.modalPresentationStyle = .fullScreen
        window.rootViewController = mainNaviBarVC
        self.dismiss(animated: true)
    }
    
    // MARK: UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        //возвращаем предыдущий (относительно переданного viewController) дочерний контроллер
        guard let imageVC = viewController as? PageViewController, let index = imageNames.firstIndex(of: imageVC.imageName) else { return nil }
        return pageAtIndex(index - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        //возвращаем следующий (относительно переданного viewController) дочерний контроллер
        guard let imageVC = viewController as? PageViewController, let index = imageNames.firstIndex(of: imageVC.imageName) else { return nil }
        return pageAtIndex(index + 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        pageControl.currentPage = currentIndex
    }
}
