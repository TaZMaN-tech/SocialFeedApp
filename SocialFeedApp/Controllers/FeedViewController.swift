//
//  FeedViewController.swift
//  SocialFeedApp
//
//  Created by Тадевос Курдоглян on 30.07.2025.
//

import UIKit

final class FeedViewController: UIViewController {
    
    // MARK: - UI Components
    private let tableView = UITableView()
    private let viewModel = FeedViewModel()
    private let footerActivityIndicator = UIActivityIndicatorView(style: .medium)
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.alpha = 0
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Social Feed"
        setupTableView()
        bindViewModel()
        viewModel.fetchInitialPosts()
    }
    
    // MARK: - Setup Methods
    private func setupTableView() {
        [tableView, errorLabel].forEach { view.addSubview($0) }
        tableView.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),

            errorLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: "PostCell")
        tableView.dataSource = self
        tableView.delegate = self

        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        tableView.refreshControl = refresh

        footerActivityIndicator.hidesWhenStopped = true
        tableView.tableFooterView = footerActivityIndicator
    }
    
    // MARK: - Bindings
    private func bindViewModel() {
        viewModel.onPostsUpdated = { [weak self] in
            self?.tableView.refreshControl?.endRefreshing()
            self?.tableView.reloadData()
        }

        viewModel.onLoadingChanged = { [weak self] isLoading in
            isLoading
                ? self?.footerActivityIndicator.startAnimating()
                : self?.footerActivityIndicator.stopAnimating()
        }

        viewModel.onError = { [weak self] in self?.showError($0) }
    }
    
    // MARK: - Error Handling
    private func showError(_ message: String) {
        errorLabel.text = message
        UIView.animate(withDuration: 0.3, animations: {
            self.errorLabel.alpha = 1
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                UIView.animate(withDuration: 0.3) {
                    self.errorLabel.alpha = 0
                }
            }
        }
    }
    
    // MARK: - Actions
    @objc private func refreshPulled() {
        viewModel.fetchInitialPosts()
    }
}

// MARK: - UITableViewDataSource
extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfPosts
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: viewModel.post(at: indexPath.row)) { [weak self] in
            self?.viewModel.toggleLike(for: indexPath.row)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FeedViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let threshold = scrollView.contentSize.height - scrollView.frame.size.height * 1.5
        guard offsetY > threshold else { return }
        viewModel.fetchMorePosts()
    }
}
