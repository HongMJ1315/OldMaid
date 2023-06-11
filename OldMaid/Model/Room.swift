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
    var roomNumber: String
    var players: [String]
    var hostPlayerID : String
    var abandonCard: [Card] = []
    var isStart: Bool
    var turn: Int
    var rank: Int
    var gameResult:[String]=[]
    var startTime: String

    enum CodingKeys: String, CodingKey {
        case id
        case deckID
        case roomID
        case roomNumber
        case players
        case hostPlayerID
        case abandonCard
        case isStart
        case turn
        case rank
        case gameResult
        case startTime
    }

    init(id: String? = nil, deckID: String, roomID: String, roomNumber: String, players: [String], hostPlayerID: String, abandonCard: [Card] = [], isStart: Bool, turn : Int, rank : Int, gameResult: [String], startTime: String) {
        self.id = id
        self.deckID = deckID
        self.roomID = roomID
        self.roomNumber = roomNumber
        self.players = players
        self.hostPlayerID = hostPlayerID
        self.abandonCard = abandonCard
        self.isStart = isStart
        self.turn = turn
        self.rank = rank
        self.gameResult = gameResult
        self.startTime = startTime
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        deckID = try container.decode(String.self, forKey: .deckID)
        roomID = try container.decode(String.self, forKey: .roomID)
        roomNumber = try container.decode(String.self, forKey: .roomNumber)
        players = try container.decode([String].self, forKey: .players)
        hostPlayerID = try container.decode(String.self, forKey: .hostPlayerID)
        abandonCard = try container.decode([Card].self, forKey: .abandonCard)
        isStart = try container.decode(Bool.self, forKey: .isStart)
        turn = try container.decode(Int.self, forKey: .turn)
        rank = try container.decode(Int.self, forKey: .rank)
        gameResult = try container.decode([String].self, forKey: .gameResult)
        startTime = try container.decode(String.self, forKey: .startTime)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(deckID, forKey: .deckID)
        try container.encode(roomID, forKey: .roomID)
        try container.encode(roomNumber, forKey: .roomNumber)
        try container.encode(players, forKey: .players)
        try container.encode(hostPlayerID, forKey: .hostPlayerID)
        try container.encode(abandonCard, forKey: .abandonCard)
        try container.encode(isStart, forKey: .isStart)
        try container.encode(turn, forKey: .turn)
        try container.encode(rank, forKey: .rank)
        try container.encode(gameResult, forKey: .gameResult)
        try container.encode(startTime, forKey: .startTime)
    }
}

func getRoomNumber() -> String {
    var roomNumber = ""
    var isUnique = false
    
    while !isUnique {
        // 生成五位随机数字
        let randomNumber = String(format: "%05d", Int.random(in: 0..<100000))
        roomNumber = randomNumber
        // 检查生成的房间号是否已存在
        isUnique = isRoomNumberUnique(roomNumber: roomNumber)
    }
    
    return roomNumber
}

func isRoomNumberUnique(roomNumber: String) -> Bool {
    var isUnique = true
    // 查询数据库以检查房间号是否已存在
    let query = db.collection("room").whereField("roomNumber", isEqualTo: roomNumber)
    query.getDocuments { (snapshot, error) in
        if let error = error {
            print("Error fetching documents: \(error)")
            isUnique = false
            return
        }
        if let documents = snapshot?.documents {
            if documents.isEmpty {
                // 房间号不存在，唯一
                isUnique = true
            } else {
                // 房间号已存在，不唯一
                isUnique = false
            }
        }
    }
    
    // 等待异步查询的结果
    while isUnique == nil {
        RunLoop.current.run(mode: .default, before: Date.distantFuture)
    }
    return isUnique
}

func createRoom(player : Player) -> String{
    let deckID : String = createDeck()
    let roomRef = db.collection("room").document()
    let roomID = roomRef.documentID
    var roomNumber = getRoomNumber()
    let room = Room(deckID: deckID, roomID: roomID, roomNumber: roomNumber, players: [], hostPlayerID: player.playerID, isStart: false, turn: -1, rank: 0, gameResult: [], startTime: "")
    do{
        try roomRef.setData(from : room)
    }catch{
        print(error)
    }
    print("room create finish")
    return roomID
}
func joinRoom(player: Player, roomID: String, completion: @escaping () -> Void) {
    let roomRef = db.collection("room").document(roomID)
    roomRef.getDocument { snapshot, error in
        guard let snapshot = snapshot, snapshot.exists, var room = try? snapshot.data(as: Room.self) else {
            completion()
            return
        }
        
        room.players.append(player.playerID)
        player.setPlayerInfo(playerID: player.playerID, roomID: room.roomID)
        do {
            try roomRef.setData(from: room) { error in
                if let error = error {
                    print(error)
                }
                completion()
            }
            print("room create finish")
        } catch {
            print(error)
            completion()
        }
    }
}

func joinRoomWithRoomNumber(player: Player, roomNumber: String, completion: @escaping (Bool) -> Void) {
    let query = db.collection("room").whereField("roomNumber", isEqualTo: roomNumber)
    query.getDocuments { snapshot, error in
        if let error = error {
            print("Error fetching documents: \(error)")
            completion(false)
            return
        }
        
        if let documents = snapshot?.documents, let room = documents.first {
            let roomID = room.documentID
            joinRoom(player: player, roomID: roomID){
                completion(true)
            }
            
        } else {
            print("Room not found")
            completion(false)
        }
    }
}


func joinRoomRandom(player: Player, completion: @escaping (Bool) -> Void) {
    db.collection("room").getDocuments { snapshot, error in
        guard let snapshot = snapshot else {
            completion(false)
            return
        }

        let rooms = snapshot.documents.compactMap { snapshot in
            try? snapshot.data(as: Room.self)
        }

        while true {
            guard let randomRoom = rooms.randomElement() else {
                completion(false)
                return
            }

            if randomRoom.players.count >= 8 {
                continue
            }
            joinRoom(player: player, roomID: randomRoom.roomID){
                completion(true)
            }
            return
        }
    }
}


func roomStart(roomID : String, completion: @escaping (Bool) -> Void){
    let roomRef = db.collection("room").document(roomID)
    var roomDeck = ""
    var players : [String] = []
    roomRef.getDocument { (snapshot, error) in
        guard let snapshot,
              snapshot.exists,
              let room = try? snapshot.data(as : Room.self) else { return }
        players = room.players
        roomDeck = room.deckID
        print("room deck id is \(roomDeck)")
        var currentPlayerIndex = 0
                
        func dealNextPlayer() {
            let currentPlayer = players[currentPlayerIndex]
            
            dealToPlayer(playerID: currentPlayer, deckID: roomDeck) { result in
                if result {
                    print("Deal success for player: \(currentPlayer)")
                    completion(false)
                } else {
                    print("Deal fail for player: \(currentPlayer)")
                    completion(true)
                    return
                }
                
                currentPlayerIndex += 1
                currentPlayerIndex %= players.count
                
                
                dealNextPlayer() // 继续处理下一个玩家
                
            }
        }
        
        dealNextPlayer() // 开始处理第一个玩家
        roomRef.updateData(["turn" : 0])
        roomRef.updateData(["rank" : players.count - 1])
        roomRef.updateData(["startTime" : "\(Date())"])
    }
}
func dealToPlayer(playerID: String, deckID: String, completion: @escaping (Bool) -> Void) {
    let playerRef = db.collection("player").document(playerID)
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
            
            
            player.deck.append(card!)
            var cardsData: [[String: Int]] = []
            for i in player.deck{
                let cardData: [String: Int] = [
                    "suit": i.suit.rawValue,
                    "rank": i.rank.rawValue
                ]
                cardsData.append(cardData)
            }
            
            do {
                playerRef.updateData([
                    "deck" : cardsData
                ])
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
        completion(roomDeck) // 将结果传递给回调函数
    }
}

func quitRoom(player : Player){
    let roomRef = db.collection("room").document(player.roomID)
    print("Call quit room \(player.roomID)")
    roomRef.getDocument { (snapshot, error) in
        guard let snapshot,
              snapshot.exists,
              var room = try? snapshot.data(as : Room.self) else { return }
        room.players.removeAll(where: {$0 == player.playerID})
        player.roomID = ""
        player.deckID = ""
        let playerRef = db.collection("player").document(player.playerID)
        roomRef.updateData(["players": room.players])
        playerRef.updateData(["roomID": ""])
        playerRef.updateData(["deckID": ""])
        if(player.playerID == room.hostPlayerID){
            roomRef.delete()
        }
    }
}

func checkRoomIlliberal(roomID : String, completion: @escaping (Bool) -> Void){
    let roomRef = db.collection("room").document(roomID)
    roomRef.getDocument { (snapshot, error) in
        guard let snapshot,
              snapshot.exists,
              let room = try? snapshot.data(as : Room.self) else {
            completion(false)
            return
        }
        completion(true)
    }
}

func checkRoomIsStart(roomID : String, completion: @escaping(Bool) ->Void){
    let roomRef = db.collection("room").document(roomID)
    roomRef.getDocument { (snapshot, error) in
        guard let snapshot,
              snapshot.exists,
              let room = try? snapshot.data(as : Room.self) else {
            completion(false)
            return
        }
        completion(room.isStart)
    }
}

func nextPlayer(roomID : String){
    let roomRef = db.collection("room").document(roomID)
    roomRef.getDocument { (snapshot, error) in
        guard let snapshot,
              snapshot.exists,
              var room = try? snapshot.data(as : Room.self) else { return }
        room.turn = (room.turn + 1) % room.players.count
        let playerRef = db.collection("player").document(room.players[room.turn])
        playerRef.getDocument { (snapshot, error) in
            guard let snapshot,
                  snapshot.exists,
                  var player = try? snapshot.data(as : Player.self) else { return }

            if(player.deck.count == 0){
                nextPlayer(roomID: roomID)
            }
            do{
                try roomRef.setData(from: room)
            } catch{
                print(error)
            }
        }
    }
}
func updateRank(roomID : String, completion: @escaping (Int) -> Void){
    let roomRef = db.collection("room").document(roomID)
    roomRef.getDocument { (snapshot, error) in
        guard let snapshot,
              snapshot.exists,
              var room = try? snapshot.data(as : Room.self) else { return }
        roomRef.updateData(["rank": room.rank - 1])
        completion(room.rank)
    }
}

func updateGameResult(roomID: String, playerID : String){
    print("update \(roomID) \(playerID)")
    let roomRef = db.collection("room").document(roomID)
    roomRef.getDocument { (snapshot, error) in
        guard let snapshot,
              snapshot.exists,
              var room = try? snapshot.data(as : Room.self) else { return }
        
        room.gameResult.append(playerID)
        
        do{
            try roomRef.setData(from: room)
        } catch{
            print(error)
        }
    }
}

func updatePlayerGameResult(playerID: [String], result: [String], startTime: String, completion: @escaping () -> Void) {
    let dispatchGroup = DispatchGroup()
    
    for i in playerID {
        print("now process \(i)")
        let playerRef = db.collection("player").document(i)
        dispatchGroup.enter() // 进入dispatch group
        
        playerRef.getDocument { (snapshot, error) in
            guard let snapshot,
                  snapshot.exists,
                  var player = try? snapshot.data(as: Player.self) else {
                dispatchGroup.leave() // 离开dispatch group（出错情况）
                return
            }
            
            print("update player game result \(i)")
            // 更新player的gameHistory字典
            player.gameHistory[startTime] = result
            
            print(player.gameHistory)
            // 将更新后的player保存回数据库
            do{
                try playerRef.setData(from: player)
                dispatchGroup.leave() // 离开dispatch group（请求完成）
            }catch{
                print(error)
                dispatchGroup.leave() // 离开dispatch group（请求完成）
            
            }
            print("update finish \(i)")
        }
    }
    
    dispatchGroup.notify(queue: .main) {
        completion() // 所有任务完成后调用completion闭包
    }
}

func closeRoom(roomID : String){
    print("close room \(roomID)")
    let roomRef = db.collection("room").document(roomID)
    roomRef.getDocument { (snapshot, error) in
        guard let snapshot, snapshot.exists,
                var room = try? snapshot.data(as: Room.self) else {return}
        roomRef.delete()
    }
}


//-------------
//Test
//----------------

//struct RoomTestView : View{
//    @State var roomID = createRoom()
//    @State var roomNumber = ""
//    
//    var body : some View{
//        Button(action : {
//            print(roomID)
//            
//        }){
//            Text("Create Room")
//        }
//        TextField("Room Number", text: $roomNumber)
//        Button(action : {
//            let player = Player(playerID: "test1")
//            joinRoomWithRoomNumber(player: player, roomNumber: roomNumber)
//        }){
//            Text("Join Room")
//        }
//        Button(action : {
//            let player = Player(playerID: "test2")
//            joinRoomRandom(player: player)
//        }){
//            Text("Join Room")
//        }
//        Button {
//            let player = Player(playerID: "test3")
//            joinRoom(player: player, roomID: roomID)
//        
//        } label: {
//            Text("Join Room")
//        }
//        Button {
//            let player = Player(playerID: "test4")
//            joinRoom(player: player, roomID: roomID)
//        
//        } label: {
//            Text("Join Room")
//        }
//        Button{
//            roomStart(roomID: roomID)
//        } label: {
//            Text("Start Game")
//        
//        }
//
//    }
//}
