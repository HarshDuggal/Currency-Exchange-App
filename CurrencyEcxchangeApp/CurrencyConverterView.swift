//
//  SwiftUIView.swift
//  CurrencyEcxchangeApp
//
//  Created by Harsh Duggal on 15/08/24.
//

import SwiftUI

struct CurrencyConverterView: View {
    @StateObject private var viewModel = CurrencyConverterViewModel()
    let columns: [GridItem] = [GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())]
    
    @State private var showAlert = false
    @State private var selectedCurrency: String = ""
    @State private var selectedAmount: Double = 0.0
    
    var body: some View {
        if viewModel.loading { // Show loading until data is fetchd
            ProgressView("Loading exchange rates...")
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
        } else {
            VStack {
                HStack{
                    TextField("Enter Amount", text: $viewModel.amount)
                        .keyboardType(.decimalPad)
                        .padding()
                    Picker("Select Currency", selection: $viewModel.selectedCurrency) {
                        ForEach(viewModel.currencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                }.border(Color.green)
                    .padding()
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(viewModel.conversionResults.sorted{$0.currency<$1.currency}) { result in
                            VStack {
                                Text(result.currency)
                                    .font(.headline)
                                Text(String(format: "%.2f", result.amount))
                                    .font(.subheadline)
                            }
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                            .onTapGesture {// Handle grid item tap and show alert
                                selectedCurrency = result.currency
                                selectedAmount = result.amount
                                showAlert = true
                            }
                        }
                    }.padding()
                }.overlay(RoundedRectangle(cornerRadius: 16).stroke(.blue, lineWidth: 2))
                
                List(viewModel.conversionResults.sorted{$0.currency<$1.currency}) { result in
                    HStack {
                        Text(result.currency)
                        Spacer()
                        //                    Text(String(format: "%.2f", result.amount * (Double(viewModel.amount) ?? 1.0)))
                        Text(String(format: "%.2f", result.amount))
                    }
                }.overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.blue, lineWidth: 2)
                )
            }
            .onAppear {
                viewModel.loadExchangeRates()
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Currency Conversion"),
                    message: Text("The amount in \(selectedCurrency) is \(String(format: "%.2f", selectedAmount))"),
                    //                       message: Text("The amount in \(selectedCurrency) is \(String(format: "%.2f", selectedAmount * (Double(viewModel.amount) ?? 1.0)))"),
                    dismissButton: .default(Text("OK Thanks"))
                )
            }
        }
    }
}

struct CurrencyConverterView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyConverterView()
    }
}

#Preview {
    CurrencyConverterView()
}
