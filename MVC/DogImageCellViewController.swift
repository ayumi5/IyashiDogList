//
//  DogImageCellViewController.swift
//  MVC
//
//  Created by 宇高あゆみ on 2022/06/02.
//

import UIKit
import IyashiDogFeature

final class DogImageCellViewController: NSObject {
    private var task: DogImageDataLoaderTask?
    private let model: Dog
    private let imageLoader: DogImageDataLoader
    
    init(model: Dog, imageLoader: DogImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func view() -> UITableViewCell {
        let cell = DogImageCell()
        cell.dogImageView.image = nil
        cell.dogImageContainer.startShimmering()
        cell.retryButton.isHidden = true
        
        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }
            
            self.task = self.imageLoader.loadImageData(from: self.model.imageURL) { [weak cell] result in
                let imageData = try? result.get()
                let image = imageData.map(UIImage.init) ?? nil
                cell?.dogImageView.image = image
                cell?.retryButton.isHidden = (image != nil)
                cell?.dogImageContainer.stopShimmering()
            }
        }
        cell.onRetry = loadImage
        loadImage()
        
        return cell
    }
    
    func preload() {
        task = imageLoader.loadImageData(from: model.imageURL) { _ in }
    }
    
    deinit {
        task?.cancel()
    }
}
