//
//  Deck.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/23.
//

import SwiftUI
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

let db = Firestore.firestore()

struct Deck: Codable{
    var cards : [Card]
}
func createDeck() -> String{
    var cards: [Card] = []
    var deckID: String = ""
    for suit in Card.Suit.allCases {
        for rank in Card.Rank.allCases {
            if(suit == Card.Suit.joker || rank == Card.Rank.joker) {continue}
            cards.append(Card(suit: suit, rank: rank))
        }
    }
    cards.append(Card(suit: Card.Suit.joker, rank: Card.Rank.joker))
    
    cards.shuffle()
    let deckRef = db.collection("deck").document()
    deckID = deckRef.documentID
    var cardsData: [[String: Int]] = []
    for card in cards {
        let cardData: [String: Int] = [
            "suit": card.suit.rawValue,
            "rank": card.rank.rawValue
        ]
        cardsData.append(cardData)
    }
    
    deckRef.setData([
        "deckID": deckID,
        "cards": cardsData
    ])
    return deckID
}

func deal(deckID: String, completion: @escaping (Card?) -> Void) {
    // 从数据库中获取牌组数据
    let deckRef = db.collection("deck").document(deckID)
    deckRef.getDocument { (document, error) in
        if let document = document, document.exists {
            let deckData = document.data()
            let cardsData = deckData?["cards"] as? [[String: Int]]
            var cards: [Card] = []
            for cardData in cardsData ?? [] {
                if let suitRawValue = cardData["suit"], let rankRawValue = cardData["rank"],
                    let suit = Card.Suit(rawValue: suitRawValue),
                    let rank = Card.Rank(rawValue: rankRawValue) {
                    let card = Card(suit: suit, rank: rank)
                    cards.append(card)
                }
            }
            if cards.isEmpty {
                completion(nil) // 没有剩余的牌，返回nil
            } else {
                let card = cards.removeFirst()
                // 将更新后的牌组保存回数据库
                saveDeck(deck: cards, deckID: deckID)
                completion(card) // 返回抽取的牌
            }
        } else {
            completion(nil) // 未找到牌组数据，返回nil
        }
    }
}

func saveDeck(deck: [Card], deckID: String) {
    let deckRef = db.collection("deck").document(deckID)
    var cardsData: [[String: Int]] = []
    for card in deck {
        let cardData: [String: Int] = [
            "suit": card.suit.rawValue,
            "rank": card.rank.rawValue
        ]
        cardsData.append(cardData)
    }
    
    deckRef.setData([
        "cards": cardsData
    ])
}
