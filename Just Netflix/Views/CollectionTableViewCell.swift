//
//  CollectionTableViewCell.swift
//  Just Netflix
//
//  Created by Айдар Оспанов on 24.08.2023.
//

import UIKit

protocol CollectionTableViewCellDelegate: AnyObject {
    func didTapCell(_ cell: CollectionTableViewCell, videoModel: TitlePreviewViewModel)
}

class CollectionTableViewCell: UITableViewCell {
    
    weak var delegate: CollectionTableViewCellDelegate?
    
    static let identifier = "CollectionTableViewCell"
    
    private var titles: [Title] = []
    
    private let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 140, height: 200)
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(
            TitleCollectionViewCell.self,
            forCellWithReuseIdentifier: TitleCollectionViewCell.identifier
        )
        return collectionView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //contentView.backgroundColor = .systemPink
        selectionStyle = .none
        contentView.addSubview(collectionView)
        delegates()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.bounds
    }
    
    func configure(with titles: [Title]) {
        self.titles = titles
        
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    private func delegates() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func downloadTitleAt(indexPath: IndexPath) {
        let title = titles[indexPath.row]
        
        StorageManager.shared.create(title)
    }
}


extension CollectionTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleCollectionViewCell.identifier, for: indexPath)
        
        guard let cell = cell as? TitleCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let title = titles[indexPath.item]
        
        cell.configure(with: title.posterPath ?? "")
        return cell
    }
    
}

extension CollectionTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let title = titles[indexPath.item]
        guard let titleName = title.originalTitle ?? title.originalName else {
            return
        }
        
        NetworkManager.shared.getMovie(with: titleName + " trailer") { [weak self] result in
            switch result {
            case .success(let videoElement):
                guard let titleOverview = title.overview else {
                    return
                }
                guard let strongSelf = self else { return }
                
                let videoModel = TitlePreviewViewModel(
                    title: titleName,
                    youtubeView: videoElement,
                    titleOverview: titleOverview
                )
                
                DispatchQueue.main.async {
                    self?.delegate?.didTapCell(strongSelf, videoModel: videoModel)
                }
               
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    
//    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
//
//    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let context = UIContextMenuConfiguration(actionProvider:  { [weak self] _ in
            let downloadAction = UIAction(title: "Download", state: .off) { _ in
                self?.downloadTitleAt(indexPath: indexPath)
            }
            return UIMenu(options: .displayInline, children: [downloadAction])
        })
        
        
        
        return context
    }
}

//extension CollectionTableViewCell: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let collectionViewWidth = collectionView.bounds.width
//        let cellWidth = collectionViewWidth / 3 - 10
//        return CGSize(width: cellWidth, height: cellWidth + 20)
//
////        CGSize(width: 140, height: 200)
//    }
//}
