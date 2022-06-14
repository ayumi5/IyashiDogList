//
//  DogImageCell.swift
//  MVP
//
//  Created by 宇高あゆみ on 2022/06/02.
//

import UIKit

public class DogImageCell: UITableViewCell {
    @IBOutlet private(set) public var dogImageContainer: UIView!
    @IBOutlet private(set) public var dogImageView: UIImageView!
    @IBOutlet private(set) public var retryButton: UIButton!
    
    var onRetry: (() -> Void)?
    
    @IBAction private func retryButtonTapped() {
       onRetry?()
    }
}
