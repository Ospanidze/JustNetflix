//
//  DownloadViewController.swift
//  Just Netflix
//
//  Created by Айдар Оспанов on 24.08.2023.
//

import UIKit

class DownloadViewController: UIViewController {
    
    private var titleItems: [TitleItem] = []
    
    private let downloadTableView: UITableView = {
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
        
        view.backgroundColor = .systemBackground
        
        title = "Downloads"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.tintColor = .white
        
        view.addSubview(downloadTableView)
        downloadTableView.rowHeight = 140
        delegates()
        fetchTitleItems()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        downloadTableView.frame = view.bounds
    }
    
    private func delegates() {
        downloadTableView.delegate = self
        downloadTableView.dataSource = self
    }
    
    private func fetchTitleItems() {
        StorageManager.shared.fetchData { [weak self] result in
            switch result {
            case .success(let titleItems):
                self?.titleItems = titleItems
                DispatchQueue.main.async {
                    self?.downloadTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension DownloadViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        titleItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath)
        
        guard let cell = cell as? TitleTableViewCell else {
            return UITableViewCell()
        }
        
        let title = titleItems[indexPath.row]
        
        cell.configure(
            with: TitleViewModel(
                titleName: title.originalName ?? title.originalTitle ?? "Unknown",
                posterURL: title.posterPath ?? ""
            )
        )
        return cell
    }
    
}

extension DownloadViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let titleItem = titleItems[indexPath.row]
            titleItems.remove(at: indexPath.row)
            downloadTableView.deleteRows(at: [indexPath], with: .fade)
            StorageManager.shared.delete(titleItem)
        }
    }
}


