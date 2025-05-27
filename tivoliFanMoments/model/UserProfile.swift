//
//  UserProfile.swift
//  tivoliFanMoments
//
//  Created by Bofur on 27.05.25.
//

import Foundation

struct UserProfile: Decodable, Hashable {
    let id: UUID
    let email: String
    var displayname: String
}
