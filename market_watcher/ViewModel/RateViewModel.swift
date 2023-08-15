//
//  RateViewModel.swift
//  market_watcher
//
//  Created by charlie on 16/6/2023.
//

import Foundation
import Combine

class RateViewModel: ObservableObject {
    //business logic
    @Published private(set) var rates = [Rate]()
    @Published private(set) var error: String = ""
    @Published private(set) var currencies = [String]()

    private let rateFetcher: ForexServiceProtocol
    private var mockPublisherList = [MockRatePublisher]()
    private var openingPrice = [String:Rate]()
    //for pipeline dispose after finish subscription
    private var disposables = Set<AnyCancellable>()
    private var numberOfPairs = 10
    //better performance than loop array in view, UI can directly take
    private(set) var percentageDictionary = [String: Double]()
    private(set) var sellBuyPriceDictionary = [String: (Double?,Double?)]()
    
    var balance: Double {
        return Double(10000 * self.currencies.count)
    }
    
    var equity: Double {
        return self.rates.reduce(0, { acc, curr in
            return acc + 10000 * curr.rate
        })
    }
    
    let margin: Double = 12345.00, used: Double = 12345.00
    
    init(rateFetcher: ForexServiceProtocol = RateFetcher()) {
        self.rateFetcher = rateFetcher
        self.fetchRate()
    }
}

extension RateViewModel {
    func fetchRate() {
        rateFetcher.getSupportedPairs()
        .retry(3)
        .receive(on: DispatchQueue.main)
        .handleEvents(receiveOutput: { self.currencies = Array($0.supportedPairs.prefix(self.numberOfPairs)) })
        .map { Array($0.supportedPairs.prefix(self.numberOfPairs))}
        .flatMap { pairs in
            //turns pairs publisher to rate publisher, call api=return publisher as need pipeline to subscrib value
            self.rateFetcher.getCurrencyRate(with: pairs)
        }
        //publisher may return error
        .retry(3)
        .map { result -> [Rate] in
            //ForexAPIResult
         switch result {
            case .success(let response):
                let rates = response.rates
                return rates.keys.map { key in
                    Rate(currency: key, rate: rates[key]!.rate, timestamp: rates[key]!.timestamp)
                }
            case .failure(let err):
                self.error = err.message
                return []
            }
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { [weak self] value in
            //ErrorResponse (api not 200)
            guard let self = self else { return }
            switch value {
            case .failure (let err):
                self.error = err.localizedDescription
            case .finished:
                break
            }
            
        }, receiveValue: { [weak self] receiveRate in
            guard let self = self else { return }
            self.rates = receiveRate
            
            for rate in receiveRate {
                //every rate init one mock publisher class, add to publisher list
                self.openingPrice[rate.currency] = rate
                let publisher = MockRatePublisher(rate: rate, changeRange: 0.03, publishInterval: 1.5)
                self.mockPublisherList.append(publisher)
            }
            
            for publisher in self.mockPublisherList {
                //every class will have subject, subscribe to subject to mock pairs' rate
                publisher.subject.sink { receiveValue in
                    //no error handling as mock subject have no error
                    let currency = receiveValue.currency
                    let rate = receiveValue.rate
  
                    guard let targetIndex = self.rates.firstIndex(where: { $0.currency == currency}) else {
                        return
                    }
                
                    // percentage change dict
                    if self.percentageDictionary[currency] != nil,
                       let openingRate = self.openingPrice[currency]?.rate {
                        self.percentageDictionary[currency] =  100.0 * (rate - openingRate) / openingRate
                    } else {
                        self.percentageDictionary[currency] = 0.0
                    }
                    
                    // sell buy dict
                    if  self.sellBuyPriceDictionary[currency] != nil {
                        self.sellBuyPriceDictionary[currency]!.0 = Double.random(in: rate * 0.9...rate)
                        self.sellBuyPriceDictionary[currency]!.1 = Double.random(in: rate...rate * 1.1)
                    } else {
                        self.sellBuyPriceDictionary[currency] = (nil,nil)
                    }
                       
                    self.rates[targetIndex] = receiveValue
                }.store(in: &self.disposables)
            }
            self.error = ""
        })
        .store(in: &disposables)
    }
}
