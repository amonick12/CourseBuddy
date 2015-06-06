//
//  Comment.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/6/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import Foundation

struct Comment {
    
    var content: String
    var courseCode: String
    var poster: String
    var date: NSDate
    var anon: Bool?
    
    init(var content: String,
        var courseCode: String,
        var poster: String,
        var date: NSDate,
        var anon: Bool?) {
            self.content = content
            self.courseCode = courseCode
            self.poster = poster
            self.date = date
            self.anon = anon
    }
}
