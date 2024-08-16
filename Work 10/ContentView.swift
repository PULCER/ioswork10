import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.rank) private var items: [Item]
    @StateObject private var navigationViewModel = NavigationViewModel()
    @Environment(\.colorScheme) var colorScheme
    
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
                styledButton(title: "Notes", color: .customYellow) {
                    navigationViewModel.navigate(to: AnyView(NotesView(navigationViewModel: navigationViewModel)))
                }
                
                styledButton(title: "Add", color: .customBlue) {
                    navigationViewModel.navigate(to: AnyView(AddItemView(modelContext: modelContext, editingItem: nil, navigationViewModel: navigationViewModel)))
                }
                
                styledButton(title: "Tasks", color: .customTeal) {
                    navigationViewModel.navigate(to: AnyView(TasksView(navigationViewModel: navigationViewModel)))
                }
            }
            .padding()
        }
    }
    
    private func styledButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(color)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    }
                )
        }
        .buttonStyle(ClickableButtonStyle())
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
