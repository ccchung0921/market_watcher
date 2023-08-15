//
//  ForexAPIMockService.swift
//  market_watcherTests
//
//  Created by Chi Chung Chan on 1/8/2022.
//

import Foundation
import Combine
import SwiftUI
@testable import market_watcher

struct ForexAPIMockService: ForexServiceProtocol {
    var supportPairAPIResult: Result<SupportPairedResponse, ErrorResponse>
    var currencyRateAPIResult: Result<ForexAPIResult, ErrorResponse>

    func getSupportedPairs() -> AnyPublisher<SupportPairedResponse, ErrorResponse> {
        self.supportPairAPIResult.publisher.eraseToAnyPublisher()
    }

    func getCurrencyRate(with currencies: [String]) -> AnyPublisher<ForexAPIResult, ErrorResponse> {
        self.currencyRateAPIResult.publisher.eraseToAnyPublisher()
    }
}
