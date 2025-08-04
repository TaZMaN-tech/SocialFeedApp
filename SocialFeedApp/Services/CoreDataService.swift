//
//  CoreDataService.swift
//  SocialFeedApp
//
//  Created by Тадевос Курдоглян on 31.07.2025.
//

import Foundation
import CoreData
import UIKit

final class CoreDataService {
    
    static let shared = CoreDataService()

    private init() {}

    // MARK: - Core Data Context
    lazy var context: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Не удалось получить AppDelegate")
        }
        return appDelegate.persistentContainer.viewContext
    }()

    // MARK: - Saving Posts
    func savePosts(_ posts: [Post]) {
        clearPosts()

        for post in posts {
            let entity = PostEntity(context: context)
            entity.id = Int64(post.id)
            entity.userId = Int64(post.userId)
            entity.title = post.title
            entity.body = post.body
            entity.isLiked = post.isLiked
        }

        do {
            try context.save()
        } catch {
            print("Ошибка при сохранении постов:", error)
        }
    }

    // MARK: - Fetching Posts
    func fetchPosts() -> [Post] {
        let request = NSFetchRequest<PostEntity>(entityName: "PostEntity")

        do {
            let entities = try context.fetch(request)
            return entities.map {
                Post(
                    id: Int($0.id),
                    userId: Int($0.userId),
                    title: $0.title ?? "",
                    body: $0.body ?? "",
                    isLiked: $0.isLiked
                )
            }
        } catch {
            print("Ошибка при получении постов:", error)
            return []
        }
    }

    // MARK: - Clearing All Posts
    func clearPosts() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PostEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            context.reset()
        } catch {
            print("Ошибка при очистке постов:", error)
        }
    }

    // MARK: - Saving Like Status
    func setLike(postID: Int, isLiked: Bool) {
        let request = NSFetchRequest<PostEntity>(entityName: "PostEntity")
        request.predicate = NSPredicate(format: "id == %d", postID)

        do {
            let results = try context.fetch(request)
            results.first?.isLiked = isLiked
            try context.save()
        } catch {
            print("Ошибка при обновлении лайка:", error)
        }
    }
}
