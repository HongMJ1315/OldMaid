//
//  RoomViewModel.swift
//  OldMaid
//
//  Created by Mr.JB on 2023/5/27.
//

import Foundation

import Firebase

class RoomViewModel: ObservableObject {
    @Published var room: Room?{ // 被監聽的物件
        willSet{
            print("get room playerr number \(newValue?.players.count)")
        }
    
    }
    var roomListener: ListenerRegistration?
    var roomID: String
    init(){
        print("room view init")
        roomID = ""
    }
    init(roomID: String) {
        print("room view init for \(roomID)")
        self.roomID = roomID
        observeRoom()
    }
    func setRoomID(roomID : String){
        self.roomID = roomID
        print("room set")
        observeRoom()
    
    }
    deinit {
        stopObservingRoom()
    }

    func observeRoom() {
        let roomRef = Firestore.firestore().collection("room").document(roomID)
        roomListener = roomRef.addSnapshotListener { [weak self] snapshot, error in
            guard let snapshot = snapshot, snapshot.exists else {
                // Room document doesn't exist or there was an error
                self?.room = nil
                return
            }

            do {
                self?.room = try snapshot.data(as: Room.self)
                self?.objectWillChange.send() // 觸發發布更新

                print("get")
                if let room = self!.room{
                    for i in room.players{
                        print(i)
                    }
                }
            } catch {
                // Failed to decode Room document
                print("Failed to decode Room:", error)
                self?.room = nil
            }
        }
    }

    func stopObservingRoom() {
        roomListener?.remove()
        roomListener = nil
    }

    func checkPlayerStatus(playerID: String) -> Bool {
        guard let room = room else {
            // Room data not available
            return false
        }

        return room.players.contains(playerID)
    }
}
