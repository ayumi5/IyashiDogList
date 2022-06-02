//
//  DogViewController.swift
//  MVC
//
//  Created by 宇高あゆみ on 2022/05/31.
//

import UIKit
import IyashiDogFeature

public final class DogViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var dogRefreshViewController: DogRefreshViewController?
    private var dogImageDataLoader: DogImageDataLoader?
    private var tableModel = [Dog]() {
        didSet { tableView.reloadData() }
    }
    private var tasks = [IndexPath:DogImageDataLoaderTask]()
    
    public convenience init(dogLoader: DogLoader, dogImageDataLoader: DogImageDataLoader) {
        self.init()
        self.dogRefreshViewController = DogRefreshViewController(dogLoader: dogLoader)
        self.dogImageDataLoader = dogImageDataLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = dogRefreshViewController?.view
        dogRefreshViewController?.onRefresh = { [weak self] dogs in
            self?.tableModel = dogs
            
        }
        tableView.prefetchDataSource = self
        dogRefreshViewController?.refresh()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dog = tableModel[indexPath.row]
        let cell = DogImageCell()
        cell.dogImageView.image = nil
        cell.dogImageContainer.startShimmering()
        cell.retryButton.isHidden = true
        
        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }
            
                self.tasks[indexPath] = self.dogImageDataLoader?.loadImageData(from: dog.imageURL) { [weak cell] result in
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
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelTask(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let cellModel = tableModel[indexPath.row]
            tasks[indexPath] = dogImageDataLoader?.loadImageData(from: cellModel.imageURL) { _ in }
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cancelTask(forRowAt: indexPath)
        }
    }
    
    private func cancelTask(forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}
