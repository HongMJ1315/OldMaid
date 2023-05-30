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
    @Published var nextPlayerID: String = ""
    @Published var nextPlayerCardNumber : Int?
    @Published var playerIndex : Int?
    @Published var nowTurn : Int?
    @Published var isChoosed : Bool?
    @Published var yourRank : Int?
    private var isObservingNextPlayer: Bool = false
    var justForRemoveMagicBug : Bool = false
    init(){
        print("Call init")
        playerID = ""
    }
    func setPlayerAndRoomID(playerID: String, roomID:String){
        print("Call set Player and Room ID")
        setPlayerID(playerID: playerID){ result in

            self.nextPlayerID = result
            self.setRoomID(roomID: roomID){_ in 
            }
            self.observePlayer()
            self.observeRoom()
            self.observeNextPlayer()
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
    func setRoomID(roomID : String, completion: @escaping (String) -> Void){
        print("set Room ID")
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
        print("Observe player")
        
        let cardRef = db.collection("player").document(playerID)
        cardRef.addSnapshotListener { (documentSnapshot, error) in
            guard let document = documentSnapshot else{
                print("no document")
                return
            }
            self.player = try? document.data(as : Player.self)
            if(self.player?.deck.count == 0){
                print("Player card empty")
                
                updateRank(roomID: self.roomID){ rank in
                    self.yourRank = rank
                }
            }
        }
    }
    func observeNextPlayer() {
        
            guard !isObservingNextPlayer else {
                return
            }

            isObservingNextPlayer = true

            print("Observe next player \(nextPlayerID)")
            let cardRef = db.collection("player").document(nextPlayerID)
            cardRef.addSnapshotListener { [weak self] documentSnapshot, error in
                guard let self = self else {
                    return
                }
            
            guard let document = documentSnapshot, document.exists else {
                print("No document")
                return
            }
            
            guard let player = try? document.data(as: Player.self) else {
                print("Player is nil")
                self.updateNextPlayerID()
                return
            }
            
            print("Next player ID: ", player.playerID, player.deck.count)
            
            if(self.nextPlayerID == self.playerID){
                print("Next player is me")
                self.yourRank = 0
                return
            }
            if (player.deck.isEmpty && self.justForRemoveMagicBug){
                print("Next player card empty")
                self.justForRemoveMagicBug = false
                self.updateNextPlayerID()
            } else {
                self.justForRemoveMagicBug = true
                self.nextPlayerCardNumber = player.deck.count
            }
            self.isObservingNextPlayer = false

        }
    }

    private func updateNextPlayerID() {
        guard let room = self.room else {
            return
        }
        
        guard let currentIndex = room.players.firstIndex(of: nextPlayerID) else {
            return
        }
        
        nextPlayerID = room.players[(currentIndex + 1) % room.players.count]
        print("Next player ID: ", nextPlayerID)
        let cardRef = db.collection("player").document(nextPlayerID)
        print("Update cardRef")
        observeNextPlayer()
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
