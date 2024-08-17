//
//  CurrencyConverterViewModel.swift
//  CurrencyEcxchangeApp
//
//  Created by Harsh Duggal on 15/08/24.
//

import SwiftUI
import Combine

class CurrencyConverterViewModel: ObservableObject {
    var exchangeRates: [String: Double] = [:]
    @Published var currencies: [String] = []
    @Published var conversionResults: [ConversionResult] = []
    @Published var loading: Bool = true // to track loading complete
    @Published var selectedCurrency: String = "USD"{
        didSet { performConversion() }
    }
    @Published var amount: String = "1"{
        didSet { performConversion() }
    }
    private let exchangeRateService = ExchangeRateService()//API service caller
    
    
    init() {
        loadExchangeRates()
    }
    
    func loadExchangeRates() { 
        if exchangeRateService.isDataStale() { // call API as date is outdated
            loading = true// loaidng starts
            exchangeRateService.fetchExchangeRates { [weak self] rates in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if let rates = rates {
                        let sortedExchangeRates = Dictionary(uniqueKeysWithValues: rates.sorted { $0.key < $1.key })
                        self.exchangeRates = sortedExchangeRates
                        self.currencies = Array(sortedExchangeRates.keys).sorted()
                        self.performConversion()
                        self.loading = false //loading ends
                    }
                }
            }
        } else if let cachedRates = exchangeRateService.loadCachedExchangeRates() { // Load cached rates
            let sortedExchangeRates = Dictionary(uniqueKeysWithValues: cachedRates.sorted { $0.key < $1.key })
            self.exchangeRates = sortedExchangeRates
            self.currencies = Array(sortedExchangeRates.keys).sorted()
            self.performConversion()
        }
    }
    
    func performConversion() {
        guard let inputAmount = Double(amount), let baseRate = exchangeRates[selectedCurrency] else { return }
        conversionResults = exchangeRates.map { currency, rate in
            let convertedAmount = (rate / baseRate) * inputAmount
            return ConversionResult(currency: currency, amount: convertedAmount)
        }
    }
}

struct ConversionResult: Identifiable {
    var id: String { currency }
    let currency: String
    let amount: Double
}

