//
//  HeaderRow.swift
//  market_watcher
//
//  Created by Chi Chung Chan on 31/7/2022.
//

import SwiftUI

struct HeaderRow: View {
    let columnName = ["Symbol", "Change", "Sell", "Buy"]
    
    var body: some View {
        HStack {
            ForEach(columnName, id: \.self) { name in
                Spacer()
                Text(name).frame(maxWidth: .infinity)
                if name == columnName.last {
                    Spacer()
                }
            }
        }
        .foregroundColor(Color(Colors.wordColor)).padding(.horizontal,8)
    }
}

struct HeaderRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HeaderRow()
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
