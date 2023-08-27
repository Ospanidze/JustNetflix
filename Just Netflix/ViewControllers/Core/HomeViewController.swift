//
//  HomeViewController.swift
//  Just Netflix
//
//  Created by Айдар Оспанов on 24.08.2023.
//

import UIKit

final class HomeViewController: UIViewController {
    
    private var randomTrendingMovie: Title?
    private var headerView: HeroHeaderView?
    
    private let sectionTitles: [String] = [
        "Trending Movies",
        "Popular",
        "Trending Tv",
        "Upcoming Movies",
        "Top rated"
    ]
    
    private let homeTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        //tableView.hea
        tableView.register(
            CollectionTableViewCell.self,
            forCellReuseIdentifier: CollectionTableViewCell.identifier
        )
        tableView.register(HeaderHomeView.self, forHeaderFooterViewReuseIdentifier: HeaderHomeView.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        
        setupViews()
        delegates()
        configureNavBar()
        //getTrendingPopular()
        
        headerView =  HeroHeaderView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 500))
        homeTableView.rowHeight = 200
        homeTableView.tableHeaderView = headerView
        configureHeaderView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        homeTableView.frame = view.bounds
    }
    
    private func setupViews() {
        view.addSubview(homeTableView)
    }
    
    private func delegates() {
        homeTableView.delegate = self
        homeTableView.dataSource = self
    }
    
    private func configureHeaderView() {
        NetworkManager.shared.getTrendingResult(from: Link.movie.url) { [weak self] result in
            switch result {
            case .success(let titles):
                let titleRandom = titles.randomElement()
                self?.randomTrendingMovie = titleRandom
                DispatchQueue.main.async {
                    self?.headerView?.configure(with: TitleViewModel(titleName: titleRandom?.originalTitle ?? "", posterURL: titleRandom?.posterPath ?? ""))
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func getTrendingPopular() {
        NetworkManager.shared.getTrendingResult(from: Link.popular.url) { result in
            switch result {
            case .success(let topRated):
                print(topRated)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func configureNavBar() {
        let image = UIImage(named: "netflixLogo")?.withRenderingMode(.alwaysOriginal)
        
        let leftBarItem = UIBarButtonItem(
            image: image,
            style: .done,
            target: self,
            action: nil
        )
        
        let rightBarItem1 = UIBarButtonItem(
            image: UIImage(systemName: "person"),
            style: .done,
            target: self,
            action: nil
        )
        
        let rightBarItem2 = UIBarButtonItem(
            image: UIImage(systemName: "play.rectangle"),
            style: .done,
            target: self,
            action: nil
        )
        
        navigationItem.leftBarButtonItem = leftBarItem
        navigationItem.rightBarButtonItems = [rightBarItem1, rightBarItem2]
        navigationController?.navigationBar.tintColor = .white
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CollectionTableViewCell.identifier, for: indexPath)
        
        guard let cell = cell as? CollectionTableViewCell else {
            return UITableViewCell()
        }
        
        cell.delegate = self
        
        switch indexPath.section {
        case Link.movie.rawValue:
            NetworkManager.shared.getTrendingResult(from: Link.movie.url) { result in
                switch result {
                case .success(let titles):
                    cell.configure(with: titles)
                case .failure(let error):
                    print(error)
                }
            }
            
        case Link.tv.rawValue:
            NetworkManager.shared.getTrendingResult(from: Link.tv.url) { result in
                switch result {
                case .success(let titles):
                    cell.configure(with: titles)
                case .failure(let error):
                    print(error)
                }
            }
        case Link.upcoming.rawValue:
            NetworkManager.shared.getTrendingResult(from: Link.upcoming.url) { result in
                switch result {
                case .success(let titles):
                    cell.configure(with: titles)
                case .failure(let error):
                    print(error)
                }
            }
        case Link.popular.rawValue:
            NetworkManager.shared.getTrendingResult(from: Link.popular.url) { result in
                switch result {
                case .success(let titles):
                    cell.configure(with: titles)
                case .failure(let error):
                    print(error)
                }
            }
        case Link.topRated.rawValue:
            NetworkManager.shared.getTrendingResult(from: Link.topRated.url) { result in
                switch result {
                case .success(let titles):
                    cell.configure(with: titles)
                case .failure(let error):
                    print(error)
                }
            }
        default: return UITableViewCell()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderHomeView.identifier) as? HeaderHomeView else {
            return nil
        }

        let sectionTitle = sectionTitles[section]
        header.setupHeader(title: sectionTitle)
        
        return header
    }
    
}

extension HomeViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        200
//    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let defaultOffset = view.safeAreaInsets.top
        let offset = scrollView.contentOffset.y + defaultOffset
        
        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -offset))
    }
}


extension HomeViewController: CollectionTableViewCellDelegate {
    func didTapCell(_ cell: CollectionTableViewCell, videoModel: TitlePreviewViewModel) {
        let vc = TitlePriviewViewController()
        vc.configure(with: videoModel)
        navigationController?.pushViewController(vc, animated: true)
    }
}
