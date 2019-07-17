//
//  WPBlogData.swift
//  WordPressBlogReader
//
//  Created on 7/13/19.
//  Copyright © 2019 Jon. All rights reserved.
//

import Foundation

struct WPBlogData {
    
    let id: Int
    let dateGMT: Date
    let title: String
    let status: String
    let link: URL

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case dateGMT = "date_gmt"
        case link
        case status
        case title
    }

}

extension WPBlogData: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(dateGMT, forKey: .dateGMT)
        try container.encode(link, forKey: .link)
        try container.encode(status, forKey: .status)
        try container.encode(["renderer": title], forKey: .title)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        dateGMT = try values.decode(Date.self, forKey: .dateGMT)
        link = try values.decode(URL.self, forKey: .link)
        status = try values.decode(String.self, forKey: .status)

        let titleValues  = try values.decode([String: String].self, forKey: .title)
        guard let titleString = titleValues["rendered"] else {
            throw DecodingError.valueNotFound(
                String.self,
                DecodingError.Context(codingPath: [CodingKeys.title],
                                      debugDescription: "`title`, `renderer` value not found")
            )
        }

        title = titleString
    }
}


struct WPLinks {
    
    let contentURL: URL
    let author: URL
    let collection: URL
    let replies: URL
    let versionHistory: URL
    
    enum CodingKeys: String, CodingKey {
        case contentURL = "self"
        case author
        case collection
        case replies
        case versionHistory = "version-history"
    }
}

extension WPLinks: Codable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        contentURL = try values.decode(URL.self, forKey: .contentURL)
        author = try values.decode(URL.self, forKey: .author)
        collection = try values.decode(URL.self, forKey: .collection)
        replies = try values.decode(URL.self, forKey: .replies)
        versionHistory = try values.decode(URL.self, forKey: .versionHistory)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(contentURL, forKey: .contentURL)
        try container.encode(author, forKey: .author)
        try container.encode(collection, forKey: .collection)
        try container.encode(replies, forKey: .replies)
        try container.encode(versionHistory, forKey: .versionHistory)
    }
}
