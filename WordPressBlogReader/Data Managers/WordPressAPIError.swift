//
//  WordPressAPIError.swift
//  WordPressBlogReader
//
//  Created on 7/13/19.
//  Copyright © 2019 Jon. All rights reserved.
//

import Foundation

enum WordPressAPIError: Error, Equatable {
    case internalError(String)
    case malformResponse
    case serverError(String)
}
