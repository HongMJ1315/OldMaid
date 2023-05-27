//
//  Player.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/23.
//

import SwiftUI
import FirebaseFirestoreSwift

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

func dealCardFromPlayer(formPlayerID: String, toPlayer: Player, cardIndex: Int){
    let formPlayerRef = db.collection("player").document(formPlayerID)
    let toPlayerRef = db.collection("player").document(toPlayer.playerID)
    formPlayerRef.getDocument { document, error in
        if let document = document, document.exists {
            let formPlayer = try! document.data(as: Player.self)
            let tmpCard = formPlayer.deck[cardIndex]
            formPlayer.deck.remove(at: cardIndex)
            formPlayerRef.setData([
                "playerID": formPlayer.playerID,
                "roomID": formPlayer.roomID,
                "deckID": formPlayer.deckID,
                "deck" : formPlayer.deck
            ])
            toPlayer.deck.append(tmpCard)
            toPlayerRef.setData([
                "playerID": toPlayer.playerID,
                "roomID": toPlayer.roomID,
                "deckID": toPlayer.deckID,
                "deck" : toPlayer.deck
            ])
        } else {
            // Document doesn't exist or there was an error
            print("Failed to retrieve room document:", error ?? "Unknown error")
        }
    }
}

func playerCardShuffle(player:Player){
    player.deck.shuffle()
    db.collection("player").document(player.playerID).setData([
        "playerID": player.playerID,
        "roomID": player.roomID,
        "deckID": player.deckID,
        "deck" : player.deck
    ])
}
func abandonCardFromPlayer(formPlayer: Player, cardIndex: Int, roomID: String){
    let tmpCard = formPlayer.deck[cardIndex]
    formPlayer.deck.remove(at: cardIndex)
    db.collection("player").document(formPlayer.playerID).setData([
        "playerID": formPlayer.playerID,
        "roomID": formPlayer.roomID,
        "deckID": formPlayer.deckID,
        "deck" : formPlayer.deck
    ])
    let roomRef = db.collection("room").document(roomID)

    roomRef.getDocument { document, error in
        if let document = document, document.exists {
            var abandonCard = document.data()?["abandonCard"] as? [Card] ?? []
            abandonCard.append(tmpCard)

            roomRef.updateData([
                "abandonCard": abandonCard
            ]) { error in
                if let error = error {
                    // Handle update failure
                    print("Failed to update abandonCard:", error)
                } else {
                    // Update successful
                    print("abandonCard updated successfully")
                }
            }
        } else {
            // Document doesn't exist or there was an error
            print("Failed to retrieve room document:", error ?? "Unknown error")
        }
    }

}


