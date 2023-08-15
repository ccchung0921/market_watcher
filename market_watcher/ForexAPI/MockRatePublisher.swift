//
//  MockRateFetcher.swift
//  market_watcher
//
//  Created by charlie on 29/7/2022.
//

import Foundation
import Combine

private protocol ForexMockServiceProtocol {
    func publishRate() -> Void
}

final class MockRatePublisher {
    //base on current value to send future subject
    private(set) var subject: CurrentValueSubject<Rate, Never>
    private var disposables = Set<AnyCancellable>()
    private let changeRange: Double
    private let publishInterval: TimeInterval
    
    init(rate: Rate, changeRange: Double, publishInterval: TimeInterval) {
        self.subject = .init(rate)
        self.changeRange = changeRange
        self.publishInterval = publishInterval

        Timer.publish(every: publishInterval, on: .main, in: .common).autoconnect().sink(receiveValue: { [weak self] _ in
            guard let self = self else { return }
            self.publishRate()
        }).store(in: &disposables)
        //store = dispose ended timeline, even the view has been deinit, there maybe still ongoing timeline, this will ensure the timline to dispose and avoid memory leak
    }
}

extension MockRatePublisher: ForexMockServiceProtocol {
    fileprivate func publishRate() {
        //calculate mock rate and send to the pipeline
        let currentRateVal = subject.value.rate
        let lowerBoundVal = currentRateVal * ( 1 - self.changeRange)
        let upperBoundVal = currentRateVal * ( 1 + self.changeRange )
        let randomGenerateVal = Double.random(in: lowerBoundVal...upperBoundVal)
        let timeInterval = Date().timeIntervalSince1970
        let IntTimeInterval = Int(timeInterval)
        subject.send(Rate(currency: subject.value.currency, rate: randomGenerateVal, timestamp: IntTimeInterval))
    }
}

