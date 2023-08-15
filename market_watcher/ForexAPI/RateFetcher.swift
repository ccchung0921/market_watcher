//
//  RateFetcher.swift
//  market_watcher
//
//  Created by charlie on 16/6/2023.
//

import Foundation
import Combine

typealias ForexAPIResult = Result<CurrentRateResponse, ForexErrorResponse>

protocol ForexServiceProtocol {
    func getSupportedPairs() -> AnyPublisher<SupportPairedResponse,ErrorResponse>
    func getCurrencyRate(with currencies: [String]) -> AnyPublisher<ForexAPIResult, ErrorResponse>
}

final class RateFetcher {
    private let session: URLSession
    
    init(session: URLSession = .shared) {  self.session = session }
}

private extension RateFetcher {
  struct ForexAPI {
    static let scheme = "https"
    static let host = "www.freeforexapi.com"
    static let path = "/api/live"
  }
  
  func makeForexApiComponents(
    with currencies: [String]
  ) -> URLComponents {
    var components = URLComponents()
    components.scheme = ForexAPI.scheme
    components.host = ForexAPI.host
    components.path = ForexAPI.path
    
    if !currencies.isEmpty {
        let queryItems = URLQueryItem(name: "pairs", value: currencies.joined(separator: ","))
        components.queryItems = [queryItems]
    }
    return components
  }
}

extension RateFetcher: ForexServiceProtocol {
    func getCurrencyRate(with currencies: [String]) -> AnyPublisher<ForexAPIResult, ErrorResponse> {
        return getRate(with: makeForexApiComponents(with: currencies))
    }
    
    func getSupportedPairs() -> AnyPublisher<SupportPairedResponse, ErrorResponse> {
        return getPairs(with: makeForexApiComponents(with: []))
    }
    
    private func getPairs(with components: URLComponents) -> AnyPublisher<SupportPairedResponse, ErrorResponse> {
        guard let url = components.url else {
            return Fail(error: ErrorResponse.network(description: "invalid url")).eraseToAnyPublisher()
        }
        return session.dataTaskPublisher(for: URLRequest(url: url))
        //call api and return publisher
                .tryMap { data, response -> Data in
                    //check callback and status code if is 200, throw error if not 200, 200 then return json data
                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                              throw URLError(.badServerResponse)
                          }
                    return data
                }
                .decode(type: SupportPairedResponse.self, decoder: JSONDecoder())
        //map throwed error
                .mapError { error in
                    switch error {
                    case is URLError:
                        return .network(description: error.localizedDescription)
                    case is Swift.DecodingError:
                        return .parsing(description: error.localizedDescription)
                    default:
                        return .parsing(description: error.localizedDescription)
                    }
                }
                .eraseToAnyPublisher()
    }
    
    private func getRate(
        with components: URLComponents) -> AnyPublisher<ForexAPIResult, ErrorResponse> {
            guard let url = components.url else {
                return Fail(error: ErrorResponse.network(description: "invalid url")).eraseToAnyPublisher()
            }
            return session.dataTaskPublisher(for: URLRequest(url: url))
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                              throw URLError(.badServerResponse)
                          }
                    return data
                }
                .tryMap { data -> ForexAPIResult in
                    let decoder = JSONDecoder()
                    do {
                        //if cannot decode then will catch
                        let response = try decoder.decode(CurrentRateResponse.self, from: data)
                        return .success(response)
                    } catch {
                        let error = try decoder.decode(ForexErrorResponse.self, from: data)
                        return .failure(error)
                    }
                }
                .mapError { error in
                    switch error {
                    case is URLError:
                        return .network(description: error.localizedDescription)
                    case is Swift.DecodingError:
                        return .parsing(description: error.localizedDescription)
                    default:
                        return .parsing(description: error.localizedDescription)
                    }
                }
                .eraseToAnyPublisher()
        }
}
