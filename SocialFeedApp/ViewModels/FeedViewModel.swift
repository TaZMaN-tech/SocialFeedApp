//
//  FeedViewModel.swift
//  SocialFeedApp
//
//  Created by Тадевос Курдоглян on 30.07.2025.
//

import Foundation

class FeedViewModel {
    // MARK: - Public Properties
    
    private(set) var posts: [Post] = [] {
        didSet {
            onPostsUpdated?()
        }
    }
    
    private var isLoading = false
    private var allLoaded = false
    private var currentOffset = 0
    private let pageSize = 20
    
    var onPostsUpdated: (() -> Void)?
    var onPostUpdated: ((Int) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Public Methods
    
    func fetchInitialPosts() {
        posts = CoreDataService.shared.fetchPosts()
        currentOffset = 0
        allLoaded = false
        fetchMorePosts()
    }
    
    
    func fetchMorePosts() {
        guard !isLoading && !allLoaded else { return }
        isLoading = true
        onLoadingChanged?(true)
        
        APIService.shared.fetchPosts(start: currentOffset, limit: pageSize) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.isLoading = false
                self.onLoadingChanged?(false)
                
                switch result {
                case .success(let newPosts):
                    if newPosts.isEmpty {
                        self.allLoaded = true
                        return
                    }
                    
                    self.posts += newPosts
                    self.currentOffset += self.pageSize
                    
                    CoreDataService.shared.savePosts(self.posts)
                    
                case .failure(let error):
                    print("Ошибка загрузки:", error)
                    self.onError?("Не удалось загрузить посты")
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
