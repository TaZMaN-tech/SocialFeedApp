//
//  PostTableViewCell.swift
//  SocialFeedApp
//
//  Created by Тадевос Курдоглян on 30.07.2025.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    // MARK: - UI Components

    private let avatarImageView = UIImageView()
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let likeButton = UIButton(type: .system)

    private var likeAction: (() -> Void)?

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        selectionStyle = .none

        // Avatar
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.clipsToBounds = true
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        // Text
        titleLabel.font = .boldSystemFont(ofSize: 16)
        bodyLabel.font = .systemFont(ofSize: 14)
        bodyLabel.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        // Like
        likeButton.setTitle("🤍", for: .normal)
        likeButton.titleLabel?.font = .systemFont(ofSize: 20)
        likeButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)

        // Main horizontal stack
        let mainStack = UIStackView(arrangedSubviews: [avatarImageView, textStack, likeButton])
        mainStack.axis = .horizontal
        mainStack.spacing = 12
        mainStack.alignment = .top
        mainStack.distribution = .fill

        contentView.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])

        // Prevent stretching
        likeButton.setContentHuggingPriority(.required, for: .horizontal)
        avatarImageView.setContentHuggingPriority(.required, for: .horizontal)
    }

    // MARK: - Configuration

    func configure(with post: Post, onLike: @escaping () -> Void) {
        titleLabel.text = post.title.capitalized
        bodyLabel.text = post.body
        likeButton.setTitle(post.isLiked ? "❤️" : "🤍", for: .normal)

        let avatarURL = UserService.shared.avatarURL(for: post.userId)
        avatarImageView.load(from: avatarURL)

        self.likeAction = onLike
    }

    // MARK: - Like Handling

    @objc private func likeTapped() {
        UIView.animate(withDuration: 0.15,
                       animations: {
                           self.likeButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                       },
                       completion: { _ in
                           UIView.animate(withDuration: 0.15) {
                               self.likeButton.transform = .identity
                           }
                       })

        likeAction?()
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        likeButton.setTitle("🤍", for: .normal)
        likeAction = nil
    }
}
