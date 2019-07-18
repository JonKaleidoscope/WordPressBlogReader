//
//  BlogPostsTableViewController.swift
//  WordPressBlogReader
//
//  Created on 7/13/19.
//  Copyright © 2019 Jon. All rights reserved.
//

import UIKit
import SafariServices

class BlogPostsTableViewController: UITableViewController {

    // MARK: - Other Properties
    var blogPosts = [WPBlogData]()
    let blogRetriever = WordPressBlogPostsRetriever()

    var spinner = UIActivityIndicatorView(style: .gray)
    var spinnerLoadingView = UIView(frame: .zero)

    // MARK: - Lifecycle Functions

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configuring and setting up views with controller
        configureTableView()
        configureLoadingView()

        // Make WordPress Blog Post API Call
        loadBlogPostData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blogPosts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = blogPosts[indexPath.row]
        cell.textLabel?.text = object.title
        cell.detailTextLabel?.text = object.link.absoluteString
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Clear Selection
        tableView.cellForRow(at: indexPath)?.isSelected = false
        let blogPost = blogPosts[indexPath.item]

        // Creating a SafariViewController for displaying WordPess blog content
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = true
        let safariVC = SFSafariViewController(url: blogPost.link, configuration: configuration)

        present(safariVC, animated: true)
    }

    // MARK: - Other Functions

    func loadBlogPostData() {
        blogRetriever.loadBlogData {[weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let response):
                print("---------WP DATA:\n\(response)")
                strongSelf.blogPosts = response.blogData
                strongSelf.tableView.reloadData()
                strongSelf.stopSpinner()
            case .failure(let error):
                print(error)
                let alert = UIAlertController(title: "Looks Like", message: "There appears to be an issues loading blog posts", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Retry", style: .default) { (_) in
                    strongSelf.loadBlogPostData()
                })
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

                strongSelf.present(alert, animated: true, completion: nil)
            }
        }
    }

    func configureTableView() {
        // Removing empty cells from tableView
        tableView.tableFooterView = UIView()
    }

    func configureLoadingView() {
        // Programmatically adding a loading view with a spinning activity indicator inside
        // since we are unable to do so in the storyboard when using a `UITableViewController`.
        spinnerLoadingView = UIView(frame: view.frame)
        spinnerLoadingView.backgroundColor = UIColor.white
        spinnerLoadingView.translatesAutoresizingMaskIntoConstraints = false

        // Adding the loading view to the ViewController
        view.addSubview(spinnerLoadingView)
        view.bringSubviewToFront(spinnerLoadingView)
        NSLayoutConstraint.activate(
            [
                spinnerLoadingView.leftAnchor.constraint(equalTo: view.leftAnchor),
                spinnerLoadingView.rightAnchor.constraint(equalTo: view.rightAnchor),
                spinnerLoadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                spinnerLoadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100)
            ]
        )

        // Adding activity indicator a the cover view
        spinnerLoadingView.addSubview(spinner)
        spinnerLoadingView.bringSubviewToFront(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                spinner.centerXAnchor.constraint(equalTo: spinnerLoadingView.centerXAnchor),
                spinner.centerYAnchor.constraint(equalTo: spinnerLoadingView.centerYAnchor)
            ]
        )

        // After the spinner and its loading view have been creating, start the loading action
        startSpinner()
    }

    func startSpinner() {
        spinner.startAnimating()
        spinnerLoadingView.isHidden = false
    }

    func stopSpinner() {
        spinner.stopAnimating()
        spinnerLoadingView.isHidden = true
    }
}
