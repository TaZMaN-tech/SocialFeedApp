//
//  APIService.swift
//  SocialFeedApp
//
//  Created by Тадевос Курдоглян on 30.07.2025.
//

import Foundation
import Alamofire

class APIService {
    static let shared = APIService()
    private init() {}

    private let baseURL = "https://jsonplaceholder.typicode.com"

    // MARK: - Загрузка постов
    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        let url = "\(baseURL)/posts"

        AF.request(url).responseDecodable(of: [Post].self) { response in
            switch response.result {
            case .success(let posts):
                completion(.success(posts))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Загрузка пользователей
    func fetchUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        let url = "\(baseURL)/users"

        AF.request(url).responseDecodable(of: [User].self) { response in
            switch response.result {
            case .success(let users):
                completion(.success(users))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
