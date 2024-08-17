//
//  ExchangeService.swift
//  CurrencyEcxchangeApp
//
//  Created by Harsh Duggal on 15/08/24.
//

import SwiftUI
import Foundation

class ExchangeRateService {
    private let apiUrl = "https://openexchangerates.org/api/latest.json"

//FIXME: add your own app id before running
#error:
    private let appId = ""// use your know id
    private let lastFetchDateKey = "LastFetchDate"// to check last loading time
    private let exchangeRatesKey = "ExchangeRates"// to update from local
    private let updateInterval:Double = 10 // 30 minutes = 30*60 seconds

    func fetchExchangeRates(completion: @escaping ([String: Double]?) -> Void) {
        
        guard let url = URL(string: "\(apiUrl)?app_id=\(appId)") else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let jsonResponse = try? JSONDecoder().decode(ExchangeRateResponse.self, from: data) {
                    self.saveExchangeRates(rates: jsonResponse.rates)
                    self.saveLastFetchDate()
                    completion(jsonResponse.rates)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    func isDataStale() -> Bool {
        if let lastFetch = UserDefaults.standard.object(forKey: lastFetchDateKey) as? Date {
            return Date().timeIntervalSince(lastFetch) > updateInterval
        }
        return true
    }
    
    func loadCachedExchangeRates() -> [String: Double]? {
        return UserDefaults.standard.dictionary(forKey: exchangeRatesKey) as? [String: Double]
    }
    
    private func saveExchangeRates(rates: [String: Double]) {
        UserDefaults.standard.set(rates, forKey: exchangeRatesKey)
    }
    
    private func saveLastFetchDate() {
        UserDefaults.standard.set(Date(), forKey: lastFetchDateKey)
    }
}

struct ExchangeRateResponse: Codable {
    let rates: [String: Double]
}
