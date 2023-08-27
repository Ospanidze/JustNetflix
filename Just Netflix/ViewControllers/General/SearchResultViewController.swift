//
//  ResultSearchViewController.swift
//  Just Netflix
//
//  Created by Айдар Оспанов on 25.08.2023.
//

import UIKit

protocol SearchResultVCDelegate: AnyObject {
    func didTappedItem(_ model: TitlePreviewViewModel)
}

class SearchResultViewController: UIViewController {
    
    weak var delegate: SearchResultVCDelegate?
    
    private var titles: [Title] = []
    
    private let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(
            width: UIScreen.main.bounds.width / 3 - 10,
            height: 200
        
        )
        flowLayout.minimumInteritemSpacing = 3
        flowLayout.minimumLineSpacing = 3
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(
            TitleCollectionViewCell.self,
            forCellWithReuseIdentifier: TitleCollectionViewCell.identifier
        )
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.frame = view.bounds
    }
    
    func configure(with titles: [Title]) {
        self.titles = titles
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

}


extension SearchResultViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleCollectionViewCell.identifier, for: indexPath)
        
        guard let cell = cell as? TitleCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let title = titles[indexPath.row]

        cell.configure(with: title.posterPath ?? "")
        return cell
    }
}

extension SearchResultViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
      
        let title = titles[indexPath.item]
        
        guard let titleName = title.originalTitle ?? title.originalName else {
            return
        }
        
        NetworkManager.shared.getMovie(with: titleName) { [weak self] result in
            switch result {
            case .success(let videoElement):
                let model = TitlePreviewViewModel(
                    title: titleName,
                    youtubeView: videoElement,
                    titleOverview: title.overview ?? ""
                )
                self?.delegate?.didTappedItem(model)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }

    }
}
