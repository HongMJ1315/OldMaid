//
//  Player.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/23.
//

import SwiftUI

class Player: ObservableObject, Codable {
    @Published var playerID: String
    @Published var roomID: String = ""
    @Published var deckID: String = ""
    @Published var deck: [Card] = []
    
    enum CodingKeys: String, CodingKey {
        case playerID, roomID, deckID, deck
    }
    init() {
        self.playerID = "null"
    }
    
    init(playerID : String) {
        self.roomID = ""
        let playerRef = db.collection("player").document(playerID)
        self.playerID = playerID
        playerRef.setData([
            "playerID": playerID,
            "roomID": roomID,
            "deckID": deckID,
            "deck" : deck
        ])
    }
    init(playerID : String, roomID : String) {
        self.roomID = roomID
        let playerRef = db.collection("player").document(playerID)
        self.playerID = playerID
        playerRef.setData([
            "playerID": playerID,
            "roomID": roomID,
            "deckID": deckID,
            "deck" : deck
        ])
    }
    
    func appendCard(card: Card) {
        deck.append(card)
    }
    
    func setRoomAndCard(deckID: String, roomID: String) {
        self.deckID = deckID
        self.roomID = roomID
        let playerRef = db.collection("player").document(playerID)
        playerRef.setData([
            "playerID": playerID,
            "roomID": roomID,
            "deckID": deckID,
            "deck" : deck
        ])
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        playerID = try container.decode(String.self, forKey: .playerID)
        roomID = try container.decode(String.self, forKey: .roomID)
        deckID = try container.decode(String.self, forKey: .deckID)
        deck = try container.decode([Card].self, forKey: .deck)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(playerID, forKey: .playerID)
        try container.encode(roomID, forKey: .roomID)
        try container.encode(deckID, forKey: .deckID)
        try container.encode(deck, forKey: .deck)
    }
}

