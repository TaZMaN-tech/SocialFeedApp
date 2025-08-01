//
//  UIImageView+Load.swift
//  SocialFeedApp
//
//  Created by Тадевос Курдоглян on 31.07.2025.
//

import UIKit

extension UIImageView {
    func load(from url: URL) {
        let key = url.absoluteString as NSString

        if let cached = ImageCache.shared.object(forKey: key) {
            self.image = cached
            return
        }

        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                ImageCache.shared.setObject(image, forKey: key)
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}
