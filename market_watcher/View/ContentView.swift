//
//  ContentView.swift
//  market_watcher
//
//  Created by charlie on 16/6/2023.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = RateViewModel()
    
    init() {
        UITabBar.appearance().backgroundColor = Colors.mainBgColor
        UITabBar.appearance().unselectedItemTintColor = Colors.wordColor
        UITableView.appearance().backgroundColor = Colors.mainBgColor
     }
    
    var body: some View {
        TabView {
            VStack {
                AppBar()

                AssetsView()
                
                HeaderRow()
            
                List(viewModel.rates.sorted { $0.currency < $1.currency }) { rate in
                    RateRow(rate: rate)
                }.listStyle(PlainListStyle())

                Text(viewModel.error).foregroundColor(.white)
            }
            .edgesIgnoringSafeArea(.top)
            .background(Color(Colors.mainBgColor))
          
            .tabItem {
                Image(systemName: "chart.line.uptrend.xyaxis")
                Text("Markets")
            }

            Text("Second Tab")
                .tabItem {
                    Image(systemName: "bag")
                    Text("Profolio")
                }
            
            Text("Third Tab")
                .tabItem {
                    Image(systemName: "bubble.left")
                    Text("Profolio")
                }
            
            Text("Fourth Tab")
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profolio")
                }
        }
        .accentColor(Color(Colors.wordColor))
        .environmentObject(viewModel)
    }
}
    
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
