//
//  User.swift
//  Vesta
//
//  Created on 2026-01-19.
//

import Foundation
import FirebaseAuth

struct AppUser: Identifiable, Codable {
    let id: String              // Firebase Auth UID
    var email: String?
    var displayName: String?
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case displayName = "display_name"
        case createdAt = "created_at"
    }
}

extension AppUser {
    /// Firebase User로부터 AppUser 생성
    init(from firebaseUser: User) {
        self.id = firebaseUser.uid
        self.email = firebaseUser.email
        self.displayName = firebaseUser.displayName
        self.createdAt = firebaseUser.metadata.creationDate ?? Date()
    }
}
