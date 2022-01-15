//
//  DogLoader.swift
//  IyashiDogList
//
//  Created by 宇高あゆみ on 2022/01/15.
//

import Foundation

protocol DogLoader {
    func load(completion: (RemoteDogLoader.Result) -> Void)
}
