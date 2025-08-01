//
//  UserService.swift
//  SocialFeedApp
//
//  Created by Тадевос Курдоглян on 31.07.2025.
//

import Foundation

class UserService {
    static let shared = UserService()

    private var users: [Int: User] = [:] // userId -> User

    private init() {}

    /// Загружает пользователей из API и сохраняет в кэш
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

    /// Возвращает пользователя по userId
    func user(for id: Int) -> User? {
        return users[id]
    }

    /// Возвращает URL для аватарки (уникальная по userId)
    func avatarURL(for id: Int) -> URL {
        return URL(string: "https://i.pravatar.cc/150?u=\(id)")!
    }
}
