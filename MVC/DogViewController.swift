//
//  DogViewController.swift
//  MVC
//
//  Created by 宇高あゆみ on 2022/05/31.
//

import UIKit
import IyashiDogFeature

public protocol DogImageDataLoaderTask {
    func cancel()
}

public protocol DogImageDataLoader {
    func loadImageData(from url: URL) -> DogImageDataLoaderTask
}

public final class DogViewController: UITableViewController {
    private var dogLoader: DogLoader?
    private var dogImageDataLoader: DogImageDataLoader?
    private var tableModel = [Dog]()
    private var tasks = [IndexPath:DogImageDataLoaderTask]()
    
    public convenience init(dogLoader: DogLoader, dogImageDataLoader: DogImageDataLoader) {
        self.init()
        self.dogLoader = dogLoader
        self.dogImageDataLoader = dogImageDataLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        dogLoader?.load { [weak self] result in
            
            if let dogs = try? result.get() {
                self?.tableModel = dogs
                self?.tableView.reloadData()
            }
            self?.refreshControl?.endRefreshing()
                    
        }
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dog = tableModel[indexPath.row]
        tasks[indexPath] = dogImageDataLoader?.loadImageData(from: dog.imageURL)
        return DogCell()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}

public class DogCell: UITableViewCell {}
