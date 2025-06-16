//
//  Reaktion.swift
//  tivoliFanMoments
//
//  Created by Bofur on 16.06.25.
//

import Foundation

enum ReactionType: String, Codable, CaseIterable {
    case like = "Like"
    case lachen = "Lachen"
    case herz = "Herz"
}

struct Reaktion: Decodable {
    let fk_upload: Int
    let fk_nutzer: Int
    let reaktion: ReactionType
}
