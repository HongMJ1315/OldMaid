//
//  Room.swift
//  OldMaid
//
//  Created by Mr.JB on 2023/5/24.
//

import Foundation
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI


struct Room: Codable, Identifiable {
    @DocumentID var id: String?
    var deckID: String
    var roomID: String
    var players: [String]
    var abandonCard: [Card] = []

    enum CodingKeys: String, CodingKey {
        case id
        case deckID
        case roomID
        case players
        case abandonCard
    }

    init(id: String? = nil, deckID: String, roomID: String, players: [String], abandonCard: [Card] = []) {
        self.id = id
        self.deckID = deckID
        self.roomID = roomID
        self.players = players
        self.abandonCard = abandonCard
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        deckID = try container.decode(String.self, forKey: .deckID)
        roomID = try container.decode(String.self, forKey: .roomID)
        players = try container.decode([String].self, forKey: .players)
        abandonCard = try container.decode([Card].self, forKey: .abandonCard)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(deckID, forKey: .deckID)
        try container.encode(roomID, forKey: .roomID)
        try container.encode(players, forKey: .players)
        try container.encode(abandonCard, forKey: .abandonCard)
    }
}

func createRoom() -> String{
    let deckID : String = createDeck()
    let roomRef = db.collection("room").document()
    let roomID = roomRef.documentID
    let room = Room(deckID: deckID, roomID: roomID, players: [])
    print("==============" + roomID + "================")
    do{
        try roomRef.setData(from : room)
    }catch{
        print(error)
    }
    return roomID
}
func joinRoom(player : Player, roomID : String){
    let roomRef = db.collection("room").document(roomID)
    roomRef.getDocument { (snapshot, error) in
        guard let snapshot,
              snapshot.exists,
              var room = try? snapshot.data(as : Room.self) else { return }
        room.players.append(player.playerID)
        player.setRoomAndCard(deckID: room.deckID, roomID: room.roomID)
        do {
            try roomRef.setData(from: room)
        } catch {
            print(error)
        }
    }
}
func roomStart(roomID : String){
    let roomRef = db.collection("room").document(roomID)
    var roomDeck = ""
    var players : [String] = []
    roomRef.getDocument { (snapshot, error) in
        guard let snapshot,
              snapshot.exists,
              let room = try? snapshot.data(as : Room.self) else { return }
        players = room.players
        roomDeck = room.deckID
     
        var currentPlayerIndex = 0
                
        func dealNextPlayer() {
            let currentPlayer = players[currentPlayerIndex]
            
            dealToPlayer(playerID: currentPlayer, deckID: roomDeck) { result in
                if result {
                    print("Deal success for player: \(currentPlayer)")
                } else {
                    print("Deal fail for player: \(currentPlayer)")
                }
                
                currentPlayerIndex += 1
                currentPlayerIndex %= players.count
                
                
                dealNextPlayer() // 继续处理下一个玩家
                
            }
        }
        
        dealNextPlayer() // 开始处理第一个玩家
        
    }
}
func dealToPlayer(playerID: String, deckID: String, completion: @escaping (Bool) -> Void) {
    let playerRef = db.collection("player").document(playerID)
    print(playerID, deckID)
    playerRef.getDocument { (snapshot, error) in
        if let error = error {
            print("Error getting player document:", error)
            completion(false) // 处理获取失败的情况
            return
        }
        
        guard let snapshot = snapshot, snapshot.exists, let player = try? snapshot.data(as: Player.self) else {
            print("Invalid player document")
            completion(false) // 处理获取失败的情况
            return
        }
        
        deal(deckID: deckID) { card in
            if card == nil {
                print("No card")
                completion(false) // 处理无卡牌的情况
                return
            }
            
            player.appendCard(card: card!)
            
            do {
                try playerRef.setData(from: player)
                completion(true) // 处理成功获取卡牌的情况
            } catch {
                print("Error updating player document:", error)
                completion(false) // 处理出错的情况
            }
        }
    }
}

func getRoomDeckID(roomID: String, completion: @escaping (String) -> Void) {
    let roomRef = db.collection("room").document(roomID)
    
    roomRef.getDocument { (snapshot, error) in
        guard let snapshot, snapshot.exists, let room = try? snapshot.data(as: Room.self) else {
            completion("") // 处理获取失败的情况
            return
        }
        
        let roomDeck = room.deckID
        print("room.deckID = " + roomDeck)
        completion(roomDeck) // 将结果传递给回调函数
    }
}

//-------------
//Test
//----------------

struct RoomTestView : View{
    @State var roomID = createRoom()
    var body : some View{
        Button(action : {
            print(roomID)
        }){
            Text("Create Room")
        }
        Button(action : {
            let player = Player(playerID: "test1")
            joinRoom(player: player, roomID: roomID)
        }){
            Text("Join Room")
        }
        Button(action : {
            let player = Player(playerID: "test2")
            joinRoom(player: player, roomID: roomID)
        }){
            Text("Join Room")
        }
        Button {
            let player = Player(playerID: "test3")
            joinRoom(player: player, roomID: roomID)
        
        } label: {
            Text("Join Room")
        }
        Button {
            let player = Player(playerID: "test4")
            joinRoom(player: player, roomID: roomID)
        
        } label: {
            Text("Join Room")
        }
        Button{
            roomStart(roomID: roomID)
        } label: {
            Text("Start Game")
        
        }

    }
}
