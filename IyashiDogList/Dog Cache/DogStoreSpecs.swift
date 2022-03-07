//
//  DogStoreSpecs.swift
//  IyashiDogList
//
//  Created by 宇高あゆみ on 2022/03/07.
//

import Foundation

public protocol CoreDataDogStoreSpecs {

   func test_retrieve_deliversEmptyOnEmptyCache()
   func test_retrieve_hasNoSideEffectsOnEmptyCache()
   func test_retrieveAfterInserting_deliversInsertedValues()
   func test_retrieve_hasNoSideEffectsOnNonEmptyCache()

   func test_insert_doesNotDeliverErrorOnEmptyCache()
   func test_insert_doesNotDeliverErrorOnNonEmptyCache()
   func test_insert_overridesPreviouslyInsertedCachedValues()
   
   func test_delete_doesNotDeliverErrorOnEmptyCache()
   func test_delete_hasNoSideEffectsOnEmptyCache()
   func test_delete_doesNotDeliverErrorOnNonEmptyCache()
   func test_delete_emptiesPreviouslyInsertedCacheValues()
   
   func test_storeSideEffects_runSerially()
}

public protocol FailableRetrieveDogStoreSpces {
   func test_retrieve_failsOnRetrievalError()
   func test_retrieve_hasNoSideEffectsOnRetrievalError()
}

public protocol FailableInsertDogStoreSpces {
   func test_insert_failsOnInsertionError()
   func test_insert_hasNoSideEffectsOnInsertionError()
}

public protocol FailableDeleteDogStoreSpces {
   func test_delete_failsOnDeletionError()
   func test_delete_hasNoSideEffectsOnDeletionError()
}

public typealias FailabeDogStoreSpecs = FailableRetrieveDogStoreSpces & FailableInsertDogStoreSpces & FailableDeleteDogStoreSpces
