//
//  DogImageCellViewController.swift
//  MVP
//
//  Created by 宇高あゆみ on 2022/06/02.
//

import UIKit

final class DogImageCellViewController: NSObject {
    private let dogImageViewModel: DogImageViewModel<UIImage>
    
    init(viewModel: DogImageViewModel<UIImage>) {
        self.dogImageViewModel = viewModel
    }
    
    private func bind(to cell: DogImageCell) {
        cell.onRetry = dogImageViewModel.loadImage
        
        dogImageViewModel.onImageLoad = { [weak cell] image in
            cell?.dogImageView.image = image
        }
        
        dogImageViewModel.onLoadingStateChange = { [weak cell] isLoading in
            cell?.dogImageContainer.isShimmering = isLoading
        }
        
        dogImageViewModel.onShouldRetryVisible = { [weak cell] shouldRetry in
            cell?.retryButton.isHidden = (shouldRetry != true)
        }
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DogImageCell") as! DogImageCell
        bind(to: cell)
        
        dogImageViewModel.loadImage()
        
        return cell
    }
    
    func preload() {
        dogImageViewModel.loadImage()
    }
    
    func cancelLoad() {
        dogImageViewModel.cancelImageLoad()
    }
}
