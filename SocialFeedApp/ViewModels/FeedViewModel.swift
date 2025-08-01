//
//  FeedViewModel.swift
//  SocialFeedApp
//
//  Created by Тадевос Курдоглян on 30.07.2025.
//

import Foundation

class FeedViewModel {
    var posts: [Post] = [] {
        didSet {
            self.onPostsUpdated?()
        }
    }
    
    var onPostsUpdated: (() -> Void)?
    
    func fetchPosts() {
        APIService.shared.fetchPosts { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let posts):
                    CoreDataService.shared.savePosts(posts)
                    self?.posts = posts
                case .failure:
                    print("Loading from CoreData")
                    self?.posts = CoreDataService.shared.fetchPosts()
                }
            }
        }
    }
    
    func post(at index: Int) -> Post {
        return posts[index]
    }
    
    func numberOfPosts() -> Int {
        return posts.count
    }
}
