//
//  LogInView.swift
//  OldMaid
//
//  Created by Mr.JB on 2023/5/26.
//

import SwiftUI

struct LogInView: View {
    @State var isLogIn = false
    @AppStorage("playerID") var playerID = "null"

    var body: some View {
        NavigationView{
            GeometryReader{ geometry in
                ZStack{
                    VStack{
                        Text("Please Roatte Your Phone")
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(geometry.size.width < geometry.size.height ? 1 : 0)
                    .zIndex(4)
                    Group{
                        VStack{
                            NavigationView{
                                VStack{
                                    HStack{
                                        Spacer()
                                        NavigationLink(destination: SignUpView(isLogIn: $isLogIn)){
                                            Text("Sign Up")
                                                .font(.system(size: 20))
                                                .foregroundColor(.white)
                                                .padding()
                                                .background(Color.blue)
                                                .cornerRadius(10)
                                        }
                                        Spacer()
                                        NavigationLink(destination: LogInFormView(isLogIn: $isLogIn)){
                                            Text("Log In")
                                                .font(.system(size: 20))
                                                .foregroundColor(.white)
                                                .padding()
                                                .background(Color.blue)
                                                .cornerRadius(10)
                                        }
                                        Spacer()
                                    }
                                    Text(playerID)
                                }
                            }
                        }
                        
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(geometry.size.width < geometry.size.height ? 0 : 1)
                    .zIndex(3)
                    .background(
                        
                        NavigationLink(destination: LobbyView(isLogIn : $isLogIn), isActive: $isLogIn) { EmptyView() }
                        
                    )
                }
            }
        }
        .onAppear{
            if playerID != "null"{
                print("playerID: \(playerID)")
                isLogIn = true
            }
            else{
                isLogIn = false
                print("not login")
            }
        
        }
    }
}

struct SignUpView : View{
    @StateObject var viewModel = LogInViewModel()
    @State var email = ""
    @State var password = ""
    @State var userName = ""
    @State var userImage = ""
    @State var showAlert = false
    @State var alertMessage = ""
    @Binding var isLogIn: Bool
    @AppStorage("playerID") var playerID = "null"
    
    @Environment(\.presentationMode) var presentationMode
    var body: some View{
        GeometryReader{ geometry in
            HStack{
                Spacer()
                VStack{
                    VStack{
                        Spacer()
                        Text(playerID)
                        HStack{
                            TextField("Email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 200)
                            
                            TextField("Password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 200)
                        }
                        HStack{
                            TextField("User Name", text: $userName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 200)
                            TextField("User Image", text: $userImage)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 200)
                        }
                        HStack{
                            Button(action: {
                                viewModel.signUp(email: email, password: password){ result in
                                    if result{
                                        viewModel.setUserInfo(userName: userName, userImage: userImage)
                                        presentationMode.wrappedValue.dismiss()
                                        isLogIn = true
                                        print("Sign Up Success \(playerID)")
                                        playerID = viewModel.user!.playerID
                                    }else{
                                        alertMessage = "Sign Up Failed"
                                        showAlert = true
                                        isLogIn = false
                                    }
                                }
                            }){
                                Text("Sign Up")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                        }
                        Spacer()
                    }
                }
                Spacer()
            }
        }
        .alert(isPresented: $showAlert){
            Alert(title: Text(alertMessage))
        }
    }
}
struct LogInFormView : View{
    @StateObject var viewModel = LogInViewModel()
    @State var email = ""
    @State var password = ""
    @State var showAlert = false
    @State var alertMessage = ""
    @Binding var isLogIn: Bool
    @AppStorage("playerID") var playerID = "null"
    @AppStorage("roomID") var roomID = "null"
    
    @Environment(\.presentationMode) var presentationMode
    var body: some View{
        GeometryReader{ geometry in
            HStack{
                Spacer()
                VStack{
                    VStack{
                        Spacer()
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 200)
                        TextField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 200)
                        HStack{
                            Button(action: {
                                viewModel.logIn(email: email, password: password){ result in
                                    if result{
                                        presentationMode.wrappedValue.dismiss()
                                        isLogIn = true
                                        playerID = viewModel.user!.playerID
                                        roomID = viewModel.user!.roomID
                                        print("Log in Success \(playerID)")
                                    }else{
                                        alertMessage = "Log In Failed"
                                        showAlert = true
                                        isLogIn = false
                                    
                                    }
                                }
                            }){
                                Text("Log In")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                        }
                        Spacer()
                    }
                    
                }
                Spacer()
            }
        }
        .alert(isPresented: $showAlert){
            Alert(title: Text(alertMessage))
        }
    }
}

//
//struct LogInView_Previews: PreviewProvider {
//    static var previews: some View {
//        LogInView()
//    }
//}
