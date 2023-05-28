//
//  GameViewModel.swift
//  OldMaid
//
//  Created by Mr.JB on 2023/5/27.
//

import Foundation

class GameViewModel : ObservableObject {
    @Published var player: Player?
    @Published var room : Room?
    var playerID: String = ""
    var roomID: String = ""
    var nextPlayerID: String = ""
    @Published var nextPlayerCardNumber : Int?
    @Published var playerIndex : Int?
    @Published var nowTurn : Int?
    @Published var isChoosed : Bool?
    init(){
        playerID = ""
    }
    init(playerID: String, roomID:String){
        setPlayerID(playerID: playerID){ result in
            print("next player id:", result)
            self.nextPlayerID = result
            self.observeNextPlayer(nextPlayerID: result )
            self.setRoomID(roomID: roomID)
            self.observePlayer()
            self.observeRoom()
        }
    }
    func setPlayerAndRoomID(playerID: String, roomID:String){
        setPlayerID(playerID: playerID){ result in
            print("next player id:", result)
            self.nextPlayerID = result
            self.observeNextPlayer(nextPlayerID: result )
            self.setRoomID(roomID: roomID)
            self.observePlayer()
            self.observeRoom()
        }
    }
    func setPlayerID(playerID: String, completion: @escaping (String) -> Void){
        self.playerID = playerID
        let playerRef = db.collection("player").document(playerID)
        playerRef.getDocument { (document, error) in
            guard let document = document, document.exists else{
                return
            }
            self.player = try? document.data(as : Player.self)
            let roomRef = db.collection("room").document(self.player!.roomID)
            roomRef.getDocument { (document, error) in
                guard let document = document, document.exists else{
                    return
                }
                let room = try? document.data(as : Room.self)
                let players = room!.players
                var playerIndex = 0
                for i in players.indices{
                    if(players[i] == self.playerID){
                        playerIndex = i
                        break
                    }
                }
                completion(players[(playerIndex + 1) % players.count])
//                self.nextPlayerID = players[(playerIndex + 1) % players.count]
            }
        }
    }
    func setRoomID(roomID : String){
        self.roomID = roomID
        let roomRef = db.collection("room").document(roomID)
        roomRef.getDocument { (document, error) in
            guard let document = document, document.exists else{
                return
            }
            self.room = try? document.data(as : Room.self)
            
            for i in self.room!.players.indices{
                if(self.room!.players[i] == self.player!.playerID){
                    self.playerIndex = i
                    return
                }
            }
        }
    }
    func observePlayer(){
        let cardRef = db.collection("player").document(playerID)
        cardRef.addSnapshotListener { (documentSnapshot, error) in
            guard let document = documentSnapshot else{
                print("no document")
                return
            }
            self.player = try? document.data(as : Player.self)
        
        }
    }
    func observeNextPlayer(nextPlayerID : String){
        let cardRef = db.collection("player").document(nextPlayerID)
        cardRef.addSnapshotListener { (documentSnapshot, error) in
            guard let document = documentSnapshot else{
                print("no document")
                return
            }
            let player = try? document.data(as : Player.self)
            self.nextPlayerCardNumber = player!.deck.count
        }
    }
    func observeRoom(){
        let roomRef = db.collection("room").document(roomID)
        roomRef.addSnapshotListener { (documentSnapshot, error) in
            guard let document = documentSnapshot else{
                print("no document")
                return
            }
            self.room = try? document.data(as : Room.self)
            if(self.room?.turn == self.playerIndex){
                self.isChoosed = true
            }
            else{
                self.isChoosed = false
            }
            print("now turn \(self.room?.turn) \(self.playerIndex) \(self.isChoosed)")
        }
    }
    func shuffle(){
        playerCardShuffle(player: player!)
    }
}
