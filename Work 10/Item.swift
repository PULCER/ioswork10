import Foundation
import SwiftData

@Model
final class Item {
    var title: String
    var itemDescription: String
    var links: [URL]
    var timestamp: Date
    var rank: Int
    
    init(title: String, itemDescription: String, links: [URL], timestamp: Date, rank: Int) {
        self.title = title
        self.itemDescription = itemDescription
        self.links = links
        self.timestamp = timestamp
        self.rank = rank
    }
}
