//
//  market_watcherTests.swift
//  market_watcherTests
//
//  Created by charlie on 16/6/2023.
//

import XCTest
import Combine
@testable import market_watcher

class market_watcherTests: XCTestCase {
    
    var disposables = Set<AnyCancellable>()

    override func tearDown() {
        disposables = []
    }

    func testFetchPairsAndRate()  {
        let supportPairRes = SupportPairedResponse(supportedPairs: ["EURUSD"], message: "123", code: 200)
        let currentRateRes = CurrentRateResponse(rates: ["EURUSD": Rates(rate: 0.3, timestamp: 11111111)], code: 200)
        let mock = ForexAPIMockService(supportPairAPIResult: .success(supportPairRes),                                      currencyRateAPIResult: .success(.success(currentRateRes)))
        let viewModel = RateViewModel(rateFetcher: mock)
        
        let promise = expectation(description: "getting 1 support pair")
        viewModel.$currencies.sink(receiveCompletion: { completion in
            
        }, receiveValue: { pairs in
            if pairs.count == 1 {
                promise.fulfill()
            }
        }).store(in: &disposables)
        
        let secondPromise = expectation(description: "getting 1 rate")
        /*
           property marked with @Published will emit its initial value,
           in this case(rates), an empty array, so use dropFirst() to ignore the first output value.
           Also, rates will be modified regularly by MockRatePublisher after getting
           rates, those values are not needed in this test, therefore, use prefix(1) to get the
           value just after initial value
         */
        viewModel.$rates.dropFirst().prefix(1).sink(receiveCompletion: { completion in
        }, receiveValue: { rates in
            if rates.count == 1 {
                secondPromise.fulfill()
            }
        }).store(in: &disposables)
        
        wait(for: [promise, secondPromise], timeout: 1)
    }
    
    func testFailFetchPairsAndRate() {
        let supportPairRes = SupportPairedResponse(supportedPairs: ["EURUSD"], message: "123", code: 200)
        let mock = ForexAPIMockService(supportPairAPIResult: .success(supportPairRes),                                      currencyRateAPIResult: .failure(ErrorResponse.network(description: "fail")))
        let viewModel = RateViewModel(rateFetcher: mock)
        
        let promise = expectation(description: "getting 1 support pair")
        viewModel.$currencies.sink(receiveCompletion: { completion in
            
        }, receiveValue: { pairs in
            if pairs.count == 1 {
                promise.fulfill()
            }
        }).store(in: &disposables)
        
        let secondPromise = expectation(description: "get error message")

        viewModel.$error.dropFirst().sink(receiveCompletion: { completion in
        }, receiveValue: { error in
            secondPromise.fulfill()
        }).store(in: &disposables)
        
        wait(for: [promise, secondPromise], timeout: 1)

    }
}
