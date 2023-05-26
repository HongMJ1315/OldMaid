//
//  MainView.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/23.
//

import SwiftUI

struct MainView: View {
    @StateObject private var gameViewModel = GameViewModel()
    var body: some View {
        Button {
            gameViewModel.test()
        } label: {
            Text("GOGO")
        }
        CardView(card: gameViewModel.playerCard, title: "Player 1")
    }
}

//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}
