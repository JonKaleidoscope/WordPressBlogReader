//
//  BlogDataFetcher.swift
//  WordPressBlogReader
//
//  Created on 7/13/19.
//  Copyright © 2019 Jon. All rights reserved.
//

import Foundation

struct WPRequestInputs {
    /// How many blog posts to load. `per_page` default number is 10
    let perPage: Int
    /// `postType` category to query post by
    let postType: String?
    
    init(perPage: Int = 10, postType: String?=nil) {
        self.perPage = perPage
        self.postType = postType
    }
    
    fileprivate var queryParameters: String {
        var queryString = "?per_page=" + String(perPage)
        if let postType = postType {
            queryString.append("&type=" + postType)
        }
        
        return queryString
    }
}

struct WPBlogHeaderData {
    // X-WP-Total
    let totalBlogPosts: Int
    // X-WP-TotalPages
    let totalBlogPages: Int
    
    init?(headers: [AnyHashable: Any]) {
        guard let totalBlogPosts = Int(headers["X-WP-Total"] as? String ?? ""),
            let totalBlogPages = Int(headers["X-WP-TotalPages"] as? String ?? "") else { return nil }
        
        self.totalBlogPosts = totalBlogPosts
        self.totalBlogPages = totalBlogPages
    }
}

struct WordPressBlogPostData {
    let blogData: [WPBlogData]
    let totalBlogPosts: Int
    let totalPages: Int
}

typealias WordPressBlogPostResult = Swift.Result<WordPressBlogPostData, WordPressAPIError>
typealias WordPressBlogPostCompletion = (WordPressBlogPostResult) -> Void

class WordPressBlogPostsRetriever {
    
    let session = URLSession(configuration: .default)
    private var dataTask: URLSessionDataTask?
    private let baseURLString = "https://demo.wp-api.org/wp-json/wp/v2/posts"
    
    /// Pulling response mapping into its own function, making it easier to unit test in isolation of URLSession, Promise/ Callback
    static func mapResponseFrom(data: Data?, urlResponse: URLResponse?, error: Error?) -> WordPressBlogPostResult {
        guard let response = urlResponse as? HTTPURLResponse, response.statusCode == 200, error == nil else {
            let mappedError = WordPressAPIError.serverError(error?.localizedDescription ?? "Bad Request")
            return .failure(mappedError)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.gmtISO8601)
        guard let data = data,
            // Getting values from the response headers in order to view multiple pages of blog posts
            let headerMetaData = WPBlogHeaderData(headers: response.allHeaderFields),
            // Decoding the JSON from the API response body
            let blogData = try? decoder.decode([WPBlogData].self, from: data) else {
                return .failure(.malformResponse)
        }
        
        // We have everything we need will create a struct containing this data
        let wordPressData = WordPressBlogPostData(blogData: blogData,
                                                  totalBlogPosts: headerMetaData.totalBlogPosts,
                                                  totalPages: headerMetaData.totalBlogPages)
        
        return .success(wordPressData)
    }
    
    /// Loads Word Press blog post data delivered in a callback
    func loadBlogData(requestInput: WPRequestInputs = WPRequestInputs(),
                      completionHandler: @escaping WordPressBlogPostCompletion) {
        dataTask?.cancel()
        let urlString = baseURLString + requestInput.queryParameters
        
        guard let url = URL(string: urlString) else {
            let errorMessage = "Unable to properly create URL for request."
            assertionFailure(errorMessage)
            completionHandler(.failure(.internalError(errorMessage)))
            return
        }
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30)
        dataTask = session.dataTask(with: request) { (data, response, error) in
            
            DispatchQueue.main.async {
                let result = WordPressBlogPostsRetriever.mapResponseFrom(data: data, urlResponse: response, error: error)
                completionHandler(result)
            }
        }
        dataTask?.resume()
    }
}
