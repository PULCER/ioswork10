import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.rank) private var items: [Item]
    @StateObject private var navigationViewModel = NavigationViewModel()
    
    var body: some View {
        ZStack {
            if let currentView = navigationViewModel.currentView {
                currentView
            } else {
                mainView
            }
        }
        .frame(minWidth: 200, idealWidth: 300, maxWidth: .infinity, minHeight: 200, idealHeight: 300, maxHeight: .infinity)
    }
    
    private var mainView: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(items) { item in
                        ItemPreview(item: item, onMoveUp: {
                            moveItem(item, direction: .up)
                        }, onMoveDown: {
                            moveItem(item, direction: .down)
                        })
                        .onTapGesture {
                            navigationViewModel.navigate(to: AnyView(AddItemView(modelContext: modelContext, editingItem: item, navigationViewModel: navigationViewModel)))
                        }
                    }
                }
                .padding()
            }
            
            Button(action: {
                navigationViewModel.navigate(to: AnyView(AddItemView(modelContext: modelContext, editingItem: nil, navigationViewModel: navigationViewModel)))
            }) {
                Text("ADD")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
    
    private func moveItem(_ item: Item, direction: MoveDirection) {
        guard let index = items.firstIndex(of: item) else { return }
        
        switch direction {
        case .up:
            guard index > 0 else { return }
            let newRank = items[index - 1].rank
            items[index - 1].rank = item.rank
            item.rank = newRank
        case .down:
            guard index < items.count - 1 else { return }
            let newRank = items[index + 1].rank
            items[index + 1].rank = item.rank
            item.rank = newRank
        }
        
        try? modelContext.save()
    }
}

enum MoveDirection {
    case up, down
}

struct ItemPreview: View {
    let item: Item
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onMoveUp) {
                Image(systemName: "arrow.up")
            }
            .padding(.trailing, 5)
            
            VStack(alignment: .leading) {
                Text(item.title ?? "Untitled")
                    .font(.headline)
                Text(item.itemDescription ?? "No description")
                    .font(.subheadline)
                    .lineLimit(1)
                
                HStack {
                    ForEach(Array(zip(item.links ?? [], 1...3)), id: \.0) { link, index in
                        Link("\(index)", destination: link)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            Button(action: onMoveDown) {
                Image(systemName: "arrow.down")
            }
            .padding(.leading, 5)
        }
    }
}
