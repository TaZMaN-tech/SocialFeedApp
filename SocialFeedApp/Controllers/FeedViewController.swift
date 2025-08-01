//
//  FeedViewController.swift
//  SocialFeedApp
//
//  Created by Тадевос Курдоглян on 30.07.2025.
//

import UIKit

class FeedViewController: UIViewController {
    private let tableView = UITableView()
    private let viewModel = FeedViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Social Feed"
        setupTableView()
        bindViewModel()
        viewModel.fetchPosts()
        
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])

        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: "PostCell")
        tableView.dataSource = self
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
    }

    private func bindViewModel() {
        viewModel.onPostsUpdated = { [weak self] in
            self?.tableView.refreshControl?.endRefreshing()
            self?.tableView.reloadData()
        }
    }

    @objc private func refreshPulled() {
        viewModel.fetchPosts()
    }
}

extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfPosts()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostTableViewCell else {
            return UITableViewCell()
        }
        let post = viewModel.post(at: indexPath.row)
        cell.configure(with: post) { [weak self] in
            self?.viewModel.toggleLike(for: indexPath.row)
        }
        return cell
    }
}
