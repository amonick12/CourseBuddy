//
//  Post.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/6/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import Foundation

struct Post {
    
    var content: String
    var courseCode: String
    var poster: String
    var date: NSDate
    var anon: Bool?
    var important: Bool?
    var comments: [Comment]
    
    init(var content: String,
        var courseCode: String,
        var poster: String,
        var date: NSDate,
        var anon: Bool?,
        var important: Bool?,
        var comments: [Comment]) {
            self.content = content
            self.courseCode = courseCode
            self.poster = poster
            self.date = date
            self.anon = anon
            self.important = important
            self.comments = comments
    }
}