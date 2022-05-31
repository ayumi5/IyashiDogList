//
//  DogViewController.swift
//  MVC
//
//  Created by 宇高あゆみ on 2022/05/31.
//

import UIKit
import IyashiDogFeature

public final class DogViewController: UITableViewController {
    private var loader: DogLoader?
    private var tableModel = [Dog]()
    private var dogItems = [Dog]()
    
    public convenience init(loader: DogLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] result in
            
            if let dogs = try? result.get() {
                self?.tableModel = dogs
                self?.tableView.reloadData()
            }
                    
            self?.refreshControl?.endRefreshing()
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return DogCell()
    }
}

public class DogCell: UITableViewCell {}
