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
    private var cellViewControllers = [IndexPath: DogImageCellViewController]()
    
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
        return cellController(forRowAt: indexPath).view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        removeCellController(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(removeCellController)
    }

    private func cellController(forRowAt indexPath: IndexPath) -> DogImageCellViewController  {
        let cellViewController = DogImageCellViewController(model: tableModel[indexPath.row], imageLoader: dogImageDataLoader!)
        cellViewControllers[indexPath] = cellViewController
        return cellViewController
    }
    
    private func removeCellController(forRowAt indexPath: IndexPath) {
        cellViewControllers[indexPath] = nil
    }
}
