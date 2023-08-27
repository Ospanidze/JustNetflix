//
//  File.swift
//  Just Netflix
//
//  Created by Айдар Оспанов on 28.08.2023.
//

import UIKit

class HeaderHomeView: UITableViewHeaderFooterView {
    
    static let identifier = "HeaderHomeView"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        //label.font = UIFont(name: "Avenir Next Bold", size: 27)
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        backgroundView?.backgroundColor = .systemBackground
        setupViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupHeader(title: String) {
        titleLabel.text = title.capitalized
    }
    
    private func setupViews() {
        addSubview(titleLabel)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }
    
}
