//
//  ViewController.swift
//  Just Netflix
//
//  Created by Айдар Оспанов on 24.08.2023.
//

import UIKit

enum Tab: String {
    case home = "Home"
    case upcoming = "Coming Soon"
    case search = "Top Searches"
    case downloads = "Downloads"
    
    var image: String {
        switch self {
        case .home:
            return "house"
        case .upcoming:
            return "play.circle"
        case .search:
            return "magnifyingglass"
        case .downloads:
            return "arrow.down.to.line"
        }
    }
}

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //configure()
        tabBar.tintColor = .label
        setupTabBar()
    }
    
    private func configure() {
//        tabBar.backgroundColor = .white
        
        tabBar.layer.borderColor = UIColor.lightGray.cgColor
        tabBar.layer.borderWidth = 1
        tabBar.layer.masksToBounds = true
    }
    
    private func setupTabBar() {
        let homeVC = createNavigationVC(
            vc: HomeViewController(),
            title: Tab.home.rawValue,
            imageTitle: Tab.home.image
        )
        
        let upcomingVC = createNavigationVC(
            vc: UpcomingViewController(),
            title: Tab.upcoming.rawValue,
            imageTitle: Tab.upcoming.image
        )
        
        let searchVC = createNavigationVC(
            vc: SearchViewController(),
            title: Tab.search.rawValue,
            imageTitle: Tab.search.image
        )
        
        let downloadsVC = createNavigationVC(
            vc: DownloadViewController(),
            title: Tab.downloads.rawValue,
            imageTitle: Tab.downloads.image
        )
        
        setViewControllers(
            [homeVC, upcomingVC, searchVC, downloadsVC],
            animated: true
        )
        
        //viewControllers = [homeVC, upcomingVC, searchVC, downloadsVC]
    }
    
    
    private func createNavigationVC(vc: UIViewController, title: String, imageTitle: String) -> UINavigationController {
        
        let tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: imageTitle),
            selectedImage: nil
        )
        
        
        let navVC = UINavigationController(rootViewController: vc)
        navVC.tabBarItem = tabBarItem
        return navVC
    }
}

