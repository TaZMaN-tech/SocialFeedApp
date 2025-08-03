//
//  Post.swift
//  SocialFeedApp
//
//  Created by Тадевос Курдоглян on 30.07.2025.
//

import Foundation

struct Post: Codable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
    var isLiked: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case id, userId, title, body
    }
}
