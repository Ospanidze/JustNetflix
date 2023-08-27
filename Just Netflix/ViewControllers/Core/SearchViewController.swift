//
//  SearchViewController.swift
//  Just Netflix
//
//  Created by Айдар Оспанов on 24.08.2023.
//

import UIKit

final class SearchViewController: UIViewController {
    private var titles: [Title] = []
    
    private let searchTableView: UITableView = {
        let tableView = UITableView()
        //tableView.hea
        tableView.register(
            TitleTableViewCell.self,
            forCellReuseIdentifier: TitleTableViewCell.identifier
        )
        //tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var searchController: UISearchController = {
        let contoller = UISearchController(searchResultsController: SearchResultViewController())
        contoller.searchBar.placeholder = "Search for Movie or TV show"
        contoller.searchBar.searchBarStyle  = .minimal
        return contoller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Search"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.tintColor = .white
        navigationItem.searchController = searchController
        
        view.addSubview(searchTableView)
        searchTableView.rowHeight = 140
        
        delegates()
        fetchDiscoveryTitles()
        searchController.searchResultsUpdater = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchTableView.frame = view.bounds
    }
    
    private func delegates() {
        searchTableView.dataSource = self
        searchTableView.delegate = self
    }
    
    private func fetchDiscoveryTitles() {
        NetworkManager.shared.getTrendingResult(from: Link.discovery.url) { [weak self] result in
            switch result {
            case .success(let titles):
                self?.titles = titles
                DispatchQueue.main.async {
                    self?.searchTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}


extension SearchViewController: UITableViewDataSource {
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

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let title = titles[indexPath.row]
        
        guard let titleName = title.originalTitle ?? title.originalName else {
            return
        }
        
        NetworkManager.shared.getMovie(with: titleName) { result in
            switch result {
            case .success(let videoElement):
                DispatchQueue.main.async { [weak self] in
                    let model = TitlePreviewViewModel(
                        title: titleName,
                        youtubeView: videoElement,
                        titleOverview: title.overview ?? ""
                    )
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

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        
        guard let query = searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              query.trimmingCharacters(in: .whitespaces).count > 3,
              let resultController = searchController.searchResultsController as?
                SearchResultViewController else { return }
        
        resultController.delegate = self
        
        NetworkManager.shared.serch(with: query) { result in
            switch result {
            case .success(let titles):
                DispatchQueue.main.async {
                   resultController.configure(with: titles)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension SearchViewController: SearchResultVCDelegate {
    func didTappedItem(_ model: TitlePreviewViewModel) {
        DispatchQueue.main.async { [weak self] in
            let vc = TitlePriviewViewController()
            vc.configure(with: model)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
