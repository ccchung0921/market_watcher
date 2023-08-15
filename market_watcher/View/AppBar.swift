//
//  AppBar.swift
//  market_watcher
//
//  Created by Chi Chung Chan on 31/7/2022.
//

import SwiftUI

struct AppBar: View {
    var bgColor = #colorLiteral(red: 0.3374643624, green: 0.2313975394, blue: 0.4988834858, alpha: 1)
    var body: some View {
        VStack(spacing: 25) {
            
            HStack {
                Spacer()
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .foregroundColor(Color(Colors.wordColor))
                    .padding()
            }
        }
        .padding(.horizontal)
        .padding(.top, (UIApplication.shared.windows.first?.safeAreaInsets.top)! + 10)
        .background(Color(Colors.appBarColor))
        .edgesIgnoringSafeArea(.top)
    }
}

struct AppBar_Previews: PreviewProvider {
    static var previews: some View {
        AppBar()
    }
}
