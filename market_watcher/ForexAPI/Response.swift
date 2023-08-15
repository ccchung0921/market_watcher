//
//  Response.swift
//  market_watcher
//
//  Created by charlie on 16/6/2023.
//

import Foundation
import Combine

struct CurrentRateResponse: Decodable {
    let rates: [String:Rates]
    let code: Int
}

struct Rates: Decodable {
    let rate: Double
    let timestamp: Int
}

struct SupportPairedResponse: Decodable {
    let supportedPairs: [String]
    let message: String
    let code: Int
}

struct Rate: Identifiable {
    //for tableview performance,
    var currency: String
    var rate: Double
    var timestamp: Int
    var id: String { currency }
}

