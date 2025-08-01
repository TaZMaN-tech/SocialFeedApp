//
//  FeedViewModel.swift
//  SocialFeedApp
//
//  Created by Тадевос Курдоглян on 30.07.2025.
//

import Foundation

class FeedViewModel {
    // MARK: - Public Properties

    var posts: [Post] = [] {
        didSet {
            onPostsUpdated?()
        }
    }

    var onPostsUpdated: (() -> Void)?
    var onPostUpdated: ((Int) -> Void)?

    // MARK: - Public Methods

    func fetchPosts() {
        // Сначала подгружаем из CoreData
        self.posts = CoreDataService.shared.fetchPosts()

        // Потом обновляем с сервера
        APIService.shared.fetchPosts { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let posts):
                    CoreDataService.shared.savePosts(posts)
                    self?.posts = posts
                case .failure(let error):
                    print("Ошибка загрузки с сервера: \(error.localizedDescription)")
                    // данные уже загружены из CoreData — не трогаем
                }
            }
        }
    }

    func numberOfPosts() -> Int {
        return posts.count
    }

    func post(at index: Int) -> Post {
        return posts[index]
    }

    func toggleLike(for index: Int) {
        guard index < posts.count else { return }

        var post = posts[index]
        post.isLiked.toggle()
        posts[index] = post

        CoreDataService.shared.setLike(postID: post.id, isLiked: post.isLiked)

        onPostUpdated?(index)
    }
}
