//
//  MainViewModel.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/23.
//

import Foundation

class GameViewModel: ObservableObject {
    @Published var playerCard: Card?
    @Published var computerCard: Card?
    @Published var playerMoney: Int = 1000
    @Published var showAlert: Bool = false
    @Published var alertTitle: String = ""
//    var deck = Deck()
    init(){
//        saveDeck(deck: deck)
    }
    func test() {
//        playerCard = deck.deal()
    }
}
