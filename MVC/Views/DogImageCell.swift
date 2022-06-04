//
//  DogImageCell.swift
//  MVC
//
//  Created by 宇高あゆみ on 2022/06/02.
//

import UIKit

public class DogImageCell: UITableViewCell {
    public var dogImageContainer = UIView()
    public var dogImageView = UIImageView()
    private(set) public lazy var retryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?
    
    @objc private func retryButtonTapped() {
       onRetry?()
    }
}
