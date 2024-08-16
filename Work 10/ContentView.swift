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
                LazyVStack(spacing: 25) {
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
            
            HStack {
                           Button(action: {
                               navigationViewModel.navigate(to: AnyView(NotesView(navigationViewModel: navigationViewModel)))
                           }) {
                               Text("Notes")
                                   .font(.headline)
                                   .foregroundColor(.black)
                                   .frame(maxWidth: .infinity)
                                   .padding()
                                   .background(Color.customYellow)
                                   .cornerRadius(10)
                           }
                           .buttonStyle(ClickableButtonStyle())
                
                Button(action: {
                    navigationViewModel.navigate(to: AnyView(AddItemView(modelContext: modelContext, editingItem: nil, navigationViewModel: navigationViewModel)))
                }) {
                    Text("Add")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.customBlue)
                        .cornerRadius(10)
                }
                .buttonStyle(ClickableButtonStyle())
                
                           Button(action: {
                               navigationViewModel.navigate(to: AnyView(TasksView(navigationViewModel: navigationViewModel)))
                           }) {
                               Text("Tasks")
                                   .font(.headline)
                                   .foregroundColor(.black)
                                   .frame(maxWidth: .infinity)
                                   .padding()
                                   .background(Color.customTeal)
                                   .cornerRadius(10)
                           }
                           .buttonStyle(ClickableButtonStyle())
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

