//
//  DogImageCellViewController.swift
//  MVP
//
//  Created by 宇高あゆみ on 2022/06/02.
//

import UIKit

protocol DogImageCellViewControllerDelegate {
    func loadDogImage()
    func cancelLoad()
}

final class DogImageCellViewController: NSObject, DogImageView {
    typealias Image = UIImage
    
    private let delegate: DogImageCellViewControllerDelegate
    private var cell: DogImageCell?
    
    init(delegate: DogImageCellViewControllerDelegate) {
        self.delegate = delegate
    }
    
    func display(_ viewModel: DogImageViewModel<UIImage>) {
        cell?.onRetry = delegate.loadDogImage
        cell?.dogImageView.image = viewModel.image
        cell?.dogImageContainer.isShimmering = viewModel.isLoading
        cell?.retryButton.isHidden = !viewModel.shouldRetry
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DogImageCell") as! DogImageCell
        self.cell = cell
        delegate.loadDogImage()
        
        return cell
    }
    
    func preload() {
        delegate.loadDogImage()
    }
    
    func cancelLoad() {
        self.cell = nil
        delegate.cancelLoad()
    }
}
