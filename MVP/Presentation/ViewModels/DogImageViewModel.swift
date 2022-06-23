//
//  DogImageViewModel.swift
//  MVP
//
//  Created by 宇高あゆみ on 2022/06/23.
//

struct DogImageViewModel<Image> {
    var image: Image?
    var isLoading: Bool
    var shouldRetry: Bool
}
