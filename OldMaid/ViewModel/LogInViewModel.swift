//
//  LogInViewModel.swift
//  OldMaid
//
//  Created by Mr.JB on 2023/5/26.
//

import Foundation
import FirebaseAuth
import SwiftUI

class LogInViewModel: ObservableObject{
    @Published var user : Player? = nil
    
    init(){
        print("init")
        Auth.auth().addStateDidChangeListener { auth, user in
            guard let userData = user else {
                return
            }
            print(userData.uid)
            self.user = Player(playerID: userData.uid, roomID: "null")
        }
    }
    
    func signUp(email: String, password: String,completion: @escaping (Bool)->Void){
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            guard let userData = result?.user,
                  error == nil else {
                completion(false)
                print(error?.localizedDescription)
                return
            }
            completion(true)
            self.user = Player(playerID: userData.uid)
            print(userData.email, userData.uid)
        }
    }
    
    func setUserInfo(userName: String, userImage: String){
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.photoURL = URL(string: userImage)
        changeRequest?.displayName = userName
        changeRequest?.commitChanges(completion: { error in
           guard error == nil else {
               print(error?.localizedDescription)
               return
           }
        })
    }
    func logIn(email: String, password: String, completion: @escaping (Bool)->Void){
        print("log in")
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            guard let userData = result?.user, error == nil else {
                print(error?.localizedDescription)
                completion(false)
                return
            }
            let playerRef = db.collection("player").document(userData.uid)
            //set roomID
            playerRef.getDocument { (document, error) in
                guard let document = document, document.exists else{
                    print("document not exist")
                    return
                }
                do{
                    let player = try document.data(as : Player.self)
                    if(player.roomID == ""){
                        playerRef.updateData(["roomID" : ""])
                    }
                    print("roomID: \(player.roomID)")
                } catch{
                    print(error)
                }
            }
            completion(true)
        }
    }
    
    func checkLogInStatus(completion: @escaping (Bool)->Void){
        if Auth.auth().currentUser != nil{
            completion(true)
        }else{
            completion(false)
        }
    }
    
    func logOut(completion: @escaping (Bool)->Void){
        do{
            try Auth.auth().signOut()
            self.user = nil
            completion(true)
        }catch{
            print(error.localizedDescription)
            completion(false)
        }
    }
}

struct logInUITest : View{
    @ObservedObject var logInViewModel = LogInViewModel()
    @State var email = ""
    @State var password = ""
    var body: some View{
        VStack{
            Text("Status: \(logInViewModel.user?.playerID ?? "nil")")
            
            TextField("email", text: $email)
            TextField("password", text: $password)
            Button("signUp"){
                logInViewModel.signUp(email: email, password: password) { success in
//                    if success{
//                        print("success")
//                    }
                }
            }
            Button("logIn"){
                logInViewModel.logIn(email: email, password: password) { success in
//                    if success{
//                        print("success")
//                    }
                }
            }
            Button("logOut"){
                logInViewModel.logOut { success in
//                    if success{
//                        print("success")
//                    }
                }
            }
            Button("check"){
                logInViewModel.checkLogInStatus { success in
//                    if success{
//                        print("success")
//                    }
//                    else{
//                        print("fail")
//                    
//                    }
                }
            }
        }
    }
}
