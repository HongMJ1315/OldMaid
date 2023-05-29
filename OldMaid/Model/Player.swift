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
        self.playerID = playerID
        self.roomID = roomID
        setPlayerInfo(playerID: playerID, roomID: roomID)
    }
    func setPlayerInfo(playerID : String, roomID : String) {
        self.roomID = roomID
        let playerRef = db.collection("player").document(playerID)
        self.playerID = playerID
        playerRef.getDocument { (document, error) in
            guard let document = document, document.exists else{
                return
            }
            
            if let player = try? document.data(as : Player.self){
                self.deck = player.deck
                self.deckID = player.deckID
            
            }
               
            
            
            var cardsData: [[String: Int]] = []
            for i in self.deck{
                let cardData: [String: Int] = [
                    "suit": i.suit.rawValue,
                    "rank": i.rank.rawValue
                ]
                cardsData.append(cardData)
            }
            playerRef.setData([
                "playerID": playerID,
                "roomID": roomID,
                "deckID": self.deckID,
                "deck" : cardsData
            
            ])
        }
    }
    
    func setRoomID(roomID: String) {
        self.roomID = roomID
        let playerRef = db.collection("player").document(playerID)
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

func dealCardFromPlayer(formPlayerID: String, toPlayer: Player, cardIndex: Int, completion: @escaping (Bool) -> Void){
    let formPlayerRef = db.collection("player").document(formPlayerID)
    let toPlayerRef = db.collection("player").document(toPlayer.playerID)
    formPlayerRef.getDocument { document, error in
        if let document = document, document.exists {
            var formPlayer = try! document.data(as: Player.self)
            let tmpCard = formPlayer.deck[cardIndex]
            
            formPlayer.deck.remove(at: cardIndex)
            var cardsData: [[String: Int]] = []
            for i in formPlayer.deck{
                let cardData: [String: Int] = [
                    "suit": i.suit.rawValue,
                    "rank": i.rank.rawValue
                ]
                cardsData.append(cardData)
            }
            formPlayerRef.setData([
                "playerID": formPlayer.playerID,
                "roomID": formPlayer.roomID,
                "deckID": formPlayer.deckID,
                "deck" : cardsData
            ])
            cardsData = []
            toPlayer.deck.append(tmpCard)
            for i in toPlayer.deck{
                let cardData: [String: Int] = [
                    "suit": i.suit.rawValue,
                    "rank": i.rank.rawValue
                ]
                cardsData.append(cardData)
            }
            
            toPlayerRef.setData([
                "playerID": toPlayer.playerID,
                "roomID": toPlayer.roomID,
                "deckID": toPlayer.deckID,
                "deck" : cardsData
            ])
            completion(true)
        } else {
            // Document doesn't exist or there was an error
            print("Failed to retrieve room document:", error ?? "Unknown error")
            completion(false)
        }
    }
}

func playerCardShuffle(player:Player){
    player.deck.shuffle()
    var cardsData: [[String: Int]] = []
    for i in player.deck{
        let cardData: [String: Int] = [
            "suit": i.suit.rawValue,
            "rank": i.rank.rawValue
        ]
        cardsData.append(cardData)
    }
    
    db.collection("player").document(player.playerID).setData([
        "playerID": player.playerID,
        "roomID": player.roomID,
        "deckID": player.deckID,
        "deck" : cardsData
    ])
}
func abandonCardFromPlayer(formPlayer: Player, firstCardIndex: Int, secondCardIndex: Int, roomID: String){
    let tmpCard = formPlayer.deck[firstCardIndex]
    let tmpCard2 = formPlayer.deck[secondCardIndex]
    var tmpFirstCardIndex = firstCardIndex
    var tmpSecondCardIndex = secondCardIndex
    if(tmpFirstCardIndex > tmpSecondCardIndex){
        swap(&tmpFirstCardIndex, &tmpSecondCardIndex)
    }
    formPlayer.deck.remove(at: tmpSecondCardIndex)
    formPlayer.deck.remove(at: tmpFirstCardIndex)
    var cardsData: [[String: Int]] = []
    for card in formPlayer.deck {
        let cardData: [String: Int] = [
            "suit": card.suit.rawValue,
            "rank": card.rank.rawValue
        ]
        cardsData.append(cardData)
    }
    db.collection("player").document(formPlayer.playerID).setData([
        "playerID": formPlayer.playerID,
        "roomID": formPlayer.roomID,
        "deckID": formPlayer.deckID,
        "deck" : cardsData
    ])
    let roomRef = db.collection("room").document(roomID)

    roomRef.getDocument { document, error in
        guard let document = document, document.exists, var room = try? document.data(as: Room.self) else{
            return
        }
        room.abandonCard.append(tmpCard)
        room.abandonCard.append(tmpCard2)
        var abandonCardsData: [[String: Int]] = []
        for card in room.abandonCard {
            let cardData: [String: Int] = [
                "suit": card.suit.rawValue,
                "rank": card.rank.rawValue
            ]
            abandonCardsData.append(cardData)
            do {
                try roomRef.setData(from: room) { error in
                    if let error = error {
                        print(error)
                    }
                }
            } catch {
                print(error)
            }
        }
        
    }

}

func resetPlayer(player : Player){
    db.collection("player").document(player.playerID).setData([
        "playerID": player.playerID,
        "roomID": "",
        "deckID": "",
        "deck" : []
    ])
}

