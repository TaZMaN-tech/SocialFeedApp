//
//  FeedViewModel.swift
//  SocialFeedApp
//
//  Created by Тадевос Курдоглян on 30.07.2025.
//

import Foundation

final class FeedViewModel {
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
    
    var numberOfPosts: Int { posts.count }
    
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
            guard let self = self else { return }

            switch result {
            case .success(let newPosts):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.onLoadingChanged?(false)

                    if newPosts.isEmpty {
                        self.allLoaded = true
                        return
                    }

                    self.posts += newPosts
                    self.currentOffset += self.pageSize

                    CoreDataService.shared.savePosts(self.posts)
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.onLoadingChanged?(false)
                    print("Ошибка загрузки:", error)
                    self.onError?("Не удалось загрузить посты")
                }
            }
        }
    }
    
    func post(at index: Int) -> Post { posts[index] }
    
    func toggleLike(for index: Int) {
        guard index < posts.count else { return }
        posts[index].isLiked.toggle()
        CoreDataService.shared.setLike(postID: posts[index].id, isLiked: posts[index].isLiked)
        onPostUpdated?(index)
    }
}
