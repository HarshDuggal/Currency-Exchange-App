//
//  ContentView.swift
//  CurrencyEcxchangeApp
//
//  Created by Harsh Duggal on 15/08/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            CurrencyConverterView()
//            CurrencyConverterView1()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
