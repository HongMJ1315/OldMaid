//
//  CardView.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/23.
//

import SwiftUI

struct CardView: View {
    let card: Card?
    let title: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.title2)
                .padding(.bottom)
            
            if let card = card {
                VStack {
                    Text(card.rank.description)
                        .font(.largeTitle)
                    
                    Text(card.suit.description)
                        .font(.title)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 100, height: 150)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: Card(suit: .spades, rank: .ace), title: "HI")
    }
}
