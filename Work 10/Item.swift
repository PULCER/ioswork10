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
    
    init(title: String = "", itemDescription: String = "", links: [URL] = [], linkTitles: [String] = [], timestamp: Date = Date(), rank: Int = 0) {
        self.title = title
        self.itemDescription = itemDescription
        self.links = links
        self.linkTitles = linkTitles
        self.timestamp = timestamp
        self.rank = rank
    }
}
