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
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}
