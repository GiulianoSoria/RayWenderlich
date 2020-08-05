//
//  Constants.swift
//  RayWenderlich
//
//  Created by Giuliano Soria Pazos on 2020-08-01.
//

import UIKit

struct EndPoints {
    static let articlesURL = "https://api.jsonbin.io/b/5ed679357741ef56a566a67f"
    static let videosURL = "https://api.jsonbin.io/b/5ed67c667741ef56a566a831"
}

enum Keys {
    static let downloads = "downloads"
    static let bookmarks = "bookmarks"
    static let completed = "completed"
    static let inProgress = "inProgress"
}

struct Images {
    static let placeholder = UIImage(named: "logo")
    static let library = UIImage(systemName: "square.stack.fill")
    static let downloads = UIImage(systemName: "arrow.down.circle.fill")
    static let removeDownload = UIImage(systemName: "xmark.circle")
    static let person = UIImage(systemName: "person.crop.circle.fill")
    static let bookmark = UIImage(systemName: "bookmark.fill")
    static let removeBookmark = UIImage(systemName: "bookmark.slash.fill")
    static let filter = UIImage(systemName: "line.horizontal.3.decrease")
    static let play = UIImage(systemName: "play.rectangle.fill")
    static let close = UIImage(systemName: "multiply")
    static let settings = UIImage(systemName: "gearshape.fill")
    static let sort = UIImage(systemName: "arrow.up.arrow.down")
    static let completed = UIImage(systemName: "checkmark.square.fill")
    static let removeCompleted = UIImage(systemName: "xmark.square.fill")
    static let share = UIImage(systemName: "square.and.arrow.up")
}
