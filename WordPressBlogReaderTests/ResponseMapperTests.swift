//
//  ResponseMapperTests.swift
//  WordPressBlogReaderTests
//
//  Created on 7/14/19.
//  Copyright © 2019 Jon. All rights reserved.
//

import XCTest
@testable import WordPressBlogReader

class ResponseMapperTests: XCTestCase {
    
    func testBlogPostsDecoding() {
        guard let data = readJSONFromFile(fileName: "BlogPosts") else {
            return XCTFail("Unable to read JSON Data from bundle.")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.gmtISO8601)

        do {
            let blogs = try decoder.decode([WPBlogData].self, from: data)
            XCTAssertEqual(blogs.count, 10)
            let blog = blogs[0]
            XCTAssertEqual(blog.link, URL(string: "https://demo.wp-api.org/2017/05/23/hello-world/"))
            XCTAssertEqual(blog.id, 1)
            XCTAssertEqual(blog.title, "Hello world!")
            XCTAssertEqual(blog.status, "publish")

        } catch {
            XCTFail("Unable to decode JSON date. Failed with error: `\(error.localizedDescription)`")
        }
    }

    func testBlogPostsResponseMapper_Success() {
        guard let data = readJSONFromFile(fileName: "BlogPosts") else {
            return XCTFail("Unable to read JSON Data from bundle.")
        }

        let headers = ["X-WP-Total": "10", "X-WP-TotalPages": "1"]
        let httpResponse = HTTPURLResponse(url: URL(string: "/")!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: headers)

        let result = WordPressBlogPostsRetriever.mapResponseFrom(data: data,
                                                                urlResponse: httpResponse,
                                                                error: nil)
        guard case .success(let response) = result else {
            return XCTFail("API request failed to return a successfull response.")
        }

        XCTAssertEqual(response.blogData.count, 10)
        let blog = response.blogData[0]
        XCTAssertEqual(blog.link, URL(string: "https://demo.wp-api.org/2017/05/23/hello-world/"))
        XCTAssertEqual(blog.id, 1)
        XCTAssertEqual(blog.title, "Hello world!")
        XCTAssertEqual(blog.status, "publish")
    }

    func testBlogPostsResponseMapper_BadRequest_400() {
        let httpResponse = HTTPURLResponse(url: URL(string: "/")!,
                                           statusCode: 400,
                                           httpVersion: nil,
                                           headerFields: nil)

        let result = WordPressBlogPostsRetriever.mapResponseFrom(data: nil,
                                                                 urlResponse: httpResponse,
                                                                 error: nil)
        guard case .failure(let error) = result else {
            return XCTFail("API request should have failed but was successful.")
        }

        XCTAssertEqual(error, WordPressAPIError.serverError("Bad Request"))
    }

    /// Makes LIVE network call to the WordPress API.
    /// Values in the asserts pass now but could change in the future if demo data changes.
    func testGetBlogPostsLive() {
        let postRetriever = WordPressBlogPostsRetriever()
        let requestExpectation = expectation(description: "Blog Post API Request")

        postRetriever.loadBlogData { (result) in
            requestExpectation.fulfill()
            guard case .success(let response) = result else {
                return XCTFail("API request failed to return a successfull response.")
            }

            XCTAssertEqual(response.blogData.first?.title, "Hello world!")
            XCTAssertEqual(response.totalBlogPosts, 12)
            XCTAssertEqual(response.totalPages, 2)
        }

        wait(for: [requestExpectation], timeout: 20)
    }

    // MARK: - Helper Functinos
    private func readJSONFromFile(fileName: String) -> Data? {
        let bundle = Bundle.init(for: ResponseMapperTests.self)
        guard let pathString = bundle.path(forResource: fileName, ofType: "json") else { return nil }
        let path = URL(fileURLWithPath: pathString)

        return try? Data(contentsOf: path)
    }
}
