//
//  RateRow.swift
//  market_watcher
//
//  Created by charlie on 16/6/2023.
//

import Foundation

import SwiftUI

struct RateRow: View {
    var rate: Rate
    @EnvironmentObject var vm: RateViewModel
    
    private var percentageChange: Double {
        return vm.percentageDictionary[rate.currency]!
    }
    
    private var sellingPrice: Double? {
        guard let price = vm.sellBuyPriceDictionary[rate.currency]!.1 else {
            return nil
        }
        return price
    }
    
    private var buyingPrice: Double? {
        guard let price = vm.sellBuyPriceDictionary[rate.currency]!.0 else {
            return nil
        }
        return price
    }

    var body: some View {
        HStack {
            Text(rate.currency).bold().foregroundColor(.white).frame(maxWidth: .infinity)

            Text("\(String(format: "%.2f", percentageChange))%").foregroundColor(percentageChange == 0 ? .gray : percentageChange > 0 ? .green : .red).frame(maxWidth: .infinity)

            Text(buyingPrice == nil ? "-" : String(format: "%.2f", buyingPrice!)).foregroundColor(.white).frame(maxWidth: .infinity)

            Text(sellingPrice == nil ? "-" :String(format: "%.2f", sellingPrice!)).foregroundColor(.white).frame(maxWidth: .infinity)
        }
        .listRowBackground(Color(Colors.mainBgColor))
    }
}

struct RateRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RateRow(rate: Rate(currency: "123", rate: .init(12.00), timestamp: 123))
            RateRow(rate: Rate(currency: "3333", rate: .init(12.00), timestamp: 123))
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
