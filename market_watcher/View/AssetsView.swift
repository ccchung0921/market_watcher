//
//  AssetsView.swift
//  market_watcher
//
//  Created by charlie on 28/7/2022.
//

import SwiftUI


struct AssetsView: View {
    @EnvironmentObject var viewModel: RateViewModel
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text("Equity").frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color(Colors.wordColor))
                    Text("$\(String(format: "%.2f", viewModel.equity))").frame(maxWidth: .infinity, alignment: .leading).foregroundColor(.white).lineLimit(1)
                }
                HStack{
                    Text("Balance").frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color(Colors.wordColor))
                    Text("$\(String(format: "%.2f", viewModel.balance))").frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.white).lineLimit(1)
                }
                
            }
            .padding(.horizontal,8).padding(.vertical,16)
            Divider().background(Color(Colors.wordColor)).padding(.vertical,8)
            VStack {
                HStack {
                    Text("Margin").frame(maxWidth: .infinity, alignment: .leading).foregroundColor(Color(Colors.wordColor))
                    Text("$\(String(viewModel.margin))")
                        .foregroundColor(.white)
                }
                HStack {
                    Text("Used").frame(maxWidth: .infinity, alignment: .leading).foregroundColor(Color(Colors.wordColor))
                    Text("$\(String(viewModel.used))")
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal,8).padding(.vertical,16)
        }
        .fixedSize(horizontal: false, vertical: true)
        .background(Color(Colors.assetsBgColor))
        .font(.subheadline)
        .foregroundColor(.white)
        .cornerRadius(8)
        .padding()
    }
}
