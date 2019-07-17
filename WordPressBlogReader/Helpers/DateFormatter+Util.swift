//
//  DateFormatter+Util.swift
//  WordPressBlogReader
//
//  Created on 7/13/19.
//  Copyright © 2019 Jon. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    static var gmtISO8601: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }
}
