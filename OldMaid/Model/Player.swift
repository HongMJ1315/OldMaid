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
    @Published var gameHistory: [String: [String]] = [:]
    
    enum CodingKeys: String, CodingKey {
        case playerID, roomID, deckID, deck, gameHistory
    }
    init() {
        self.playerID = "null"
    }
    
    init(playerID : String) {
        print("run player init only playerID \(playerID)")
        self.roomID = ""
        let playerRef = db.collection("player").document(playerID)
        self.playerID = playerID
        
        playerRef.setData([
            "playerID": playerID,
            "roomID": roomID,
            "deckID": deckID,
            "deck" : deck,
            "gameHistory" : [:]
        ])
    }
    init(playerID : String, roomID : String) {
        self.playerID = playerID
        self.roomID = roomID
        setPlayerInfo(playerID: playerID, roomID: roomID)
    }
    func setPlayerInfo(playerID : String, roomID : String) {
        print("set playerInfo \(playerID) \(roomID)")
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
            playerRef.updateData(["playerID": playerID])
            playerRef.updateData(["roomID": roomID])
            playerRef.updateData(["deck": cardsData])
        }
    }
    
    func setRoomID(roomID: String) {
        self.roomID = roomID
        let playerRef = db.collection("player").document(playerID)
        playerRef.updateData(["roomID": roomID])
    }

    

    
    
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        playerID = try container.decode(String.self, forKey: .playerID)
        roomID = try container.decode(String.self, forKey: .roomID)
        deckID = try container.decode(String.self, forKey: .deckID)

        if let cardsData = try container.decodeIfPresent([[String: Int]].self, forKey: .deck) {
            deck = cardsData.compactMap { cardData in
                if let suitValue = cardData["suit"], let rankValue = cardData["rank"],
                    let suit = Card.Suit(rawValue: suitValue), let rank = Card.Rank(rawValue: rankValue) {
                    return Card(suit: suit, rank: rank)
                }
                return nil
            }
        } else {
            deck = []
        }

        gameHistory = try container.decode([String: [String]].self, forKey: .gameHistory)
    
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(playerID, forKey: .playerID)
        try container.encode(roomID, forKey: .roomID)
        try container.encode(deckID, forKey: .deckID)
        try container.encode(deck, forKey: .deck)
        try container.encode(gameHistory, forKey: .gameHistory)
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
            formPlayerRef.updateData([
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
            
            toPlayerRef.updateData([
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
    
    db.collection("player").document(player.playerID).updateData(["deck": cardsData])
   
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
    db.collection("player").document(formPlayer.playerID).updateData([
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
                try roomRef.updateData(["abandonCard": abandonCardsData]) { error in
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
    db.collection("player").document(player.playerID).updateData(["playerID": player.playerID])
    db.collection("player").document(player.playerID).updateData(["roomID": ""])
    db.collection("player").document(player.playerID).updateData(["deckID": ""])
    db.collection("player").document(player.playerID).updateData(["deck": [Card]()])
}

