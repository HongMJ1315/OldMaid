//
//  OldMaidApp.swift
//  OldMaid
//
//  Created by Mr.JB on 2023/5/24.
//

import SwiftUI
import Foundation
import Firebase
@main
struct OldMaidApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            RoomTestView()
        
        }
    }
}
