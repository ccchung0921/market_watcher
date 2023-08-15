//
//  ErrorResponse.swift
//  market_watcher
//
//  Created by charlie on 16/6/2023.
//

import Foundation

struct ForexErrorResponse: Decodable, Error {
    let message: String
    let code: Int
}

enum ErrorResponse: Error {
  case parsing(description: String)
  case network(description: String)
}
