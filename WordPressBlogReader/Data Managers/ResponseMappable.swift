//
//  ResponseMappable.swift
//  WordPressBlogReader
//
//  Created on 7/13/19.
//  Copyright © 2019 Jon. All rights reserved.
//

import Foundation

protocol ResponseMappable {
    
    associatedtype ReturnResult
    static func mapResponseFrom(data: Data?, urlResponse: URLResponse?, error: Error?) -> ReturnResult
}
