import Foundation
import SwiftData

@Model
final class Item {
    var title: String?
    var itemDescription: String?
    var links: [URL]?
    var linkTitles: [String]?
    var timestamp: Date?
    var rank: Int?
    var tasks: [String]?
    
    init(title: String = "", itemDescription: String = "", links: [URL] = [], linkTitles: [String] = [], timestamp: Date = Date(), rank: Int = 0, tasks: [String] = []) {
        self.title = title
        self.itemDescription = itemDescription
        self.links = links
        self.linkTitles = linkTitles
        self.timestamp = timestamp
        self.rank = rank
        self.tasks = tasks
    }
}

@Model
final class Notes {
    var title: String?
    var notesDescription: String?
    var links: [URL]?
    var linkTitles: [String]?
    var timestamp: Date?
    var rank: Int?
    
    init(title: String = "", notesDescription: String = "", links: [URL] = [], linkTitles: [String] = [], timestamp: Date = Date(), rank: Int = 0) {
        self.title = title
        self.notesDescription = notesDescription
        self.links = links
        self.linkTitles = linkTitles
        self.timestamp = timestamp
        self.rank = rank
    }
}

// New inconsequential model
@Model
final class DummyModel {
    var text: String?
    
    init(text: String = "") {
        self.text = text
    }
}

// New inconsequential model
@Model
final class DummyModel2 {
    var text: String?
    
    init(text: String = "") {
        self.text = text
    }
}

