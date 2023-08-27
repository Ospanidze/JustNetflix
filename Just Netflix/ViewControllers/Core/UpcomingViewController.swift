//
//  UpcomingViewController.swift
//  Just Netflix
//
//  Created by Айдар Оспанов on 24.08.2023.
//

import UIKit

class UpcomingViewController: UIViewController {
    
    private var titles: [Title] = []
    
    private let upcomingTableView: UITableView = {
        let tableView = UITableView()
        //tableView.hea
        tableView.register(
            TitleTableViewCell.self,
            forCellReuseIdentifier: TitleTableViewCell.identifier
        )
        //tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Upcoming"
        view.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.tintColor = .white
        view.addSubview(upcomingTableView)
        upcomingTableView.rowHeight = 140
        
        delegates()
        fetchUpcomingTitles()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        upcomingTableView.frame = view.bounds
    }
    
    private func delegates() {
        upcomingTableView.dataSource = self
        upcomingTableView.delegate = self
    }
    
    private func fetchUpcomingTitles() {
        NetworkManager.shared.getTrendingResult(from: Link.upcoming.url) { [weak self] result in
            switch result {
            case .success(let titles):
                self?.titles = titles
                DispatchQueue.main.async {
                    self?.upcomingTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}


extension UpcomingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath)
        
        guard let cell = cell as? TitleTableViewCell else {
            return UITableViewCell()
        }
        
        let title = titles[indexPath.row]
        
        cell.configure(
            with: TitleViewModel(
                titleName: title.originalName ?? title.originalTitle ?? "Unknown",
                posterURL: title.posterPath ?? ""
            )
        )
        return cell
    }
    
    
}

extension UpcomingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let title = titles[indexPath.row]
        
        guard let titleName = title.originalTitle ?? title.originalName else {
            return
        }
        
        NetworkManager.shared.getMovie(with: titleName) { result in
            switch result {
            case .success(let videoElement):
                
                let model = TitlePreviewViewModel(
                    title: titleName,
                    youtubeView: videoElement,
                    titleOverview: title.overview ?? ""
                )
                DispatchQueue.main.async { [weak self] in
                    let vc = TitlePriviewViewController()
                    vc.configure(with: model)
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
}
