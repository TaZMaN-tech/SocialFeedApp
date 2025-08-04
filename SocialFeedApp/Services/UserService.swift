//
//  UserService.swift
//  SocialFeedApp
//
//  Created by Тадевос Курдоглян on 31.07.2025.
//

import Foundation

final class UserService {
    static let shared = UserService()

    private var users: [Int: User] = [:]

    private init() {}

    func loadUsers(completion: @escaping () -> Void) {
        APIService.shared.fetchUsers { result in
            switch result {
            case .success(let fetchedUsers):
                for user in fetchedUsers {
                    self.users[user.id] = user
                }
            case .failure(let error):
                print("Ошибка загрузки пользователей:", error.localizedDescription)
            }
            completion()
        }
    }

    func user(for id: Int) -> User? {
        return users[id]
    }

    func avatarURL(for id: Int) -> URL {
        return URL(string: "https://i.pravatar.cc/150?u=\(id)")!
    }
}
