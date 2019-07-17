//
//  WPPostType.swift
//  WordPressBlogReader
//
//  Created on 7/13/19.
//  Copyright © 2019 Jon. All rights reserved.
//

import Foundation

struct WPPostType: Decodable {
    let name: String
    let slug: String
    let meta: WPLinks
    
    enum CodingKeys: String, CodingKey {
        case name
        case slug
        case meta
    }
    
    enum LinksCodingKeys: String, CodingKey {
        case links
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        slug = try values.decode(String.self, forKey: .slug)
        
        let metaValues = try values.nestedContainer(keyedBy: LinksCodingKeys.self, forKey: .meta)
        meta = try metaValues.decode(WPLinks.self, forKey: .links)
    }
    
    struct WPLinks: Codable {
        let contentURL: URL
        let taxonomy: URL
        let collection: URL
        let archives: URL?
        
        enum CodingKeys: String, CodingKey {
            case contentURL = "self"
            case taxonomy = "http://wp-api.org/1.1/collections/taxonomy/"
            case collection
            case archives

        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            contentURL = try values.decode(URL.self, forKey: .contentURL)
            taxonomy = try values.decode(URL.self, forKey: .taxonomy)
            collection = try values.decode(URL.self, forKey: .collection)
            archives = try? values.decode(URL.self, forKey: .archives)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(contentURL, forKey: .contentURL)
            try container.encode(taxonomy, forKey: .taxonomy)
            try container.encode(collection, forKey: .collection)
            try container.encode(archives, forKey: .archives)
        }
    }
}
