import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
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
        ZStack {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(items) { item in
                        ItemPreview(item: item)
                            .onTapGesture {
                                navigationViewModel.navigate(to: AnyView(AddItemView(modelContext: modelContext, editingItem: item, navigationViewModel: navigationViewModel)))
                            }
                    }
                }
                .padding()
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        navigationViewModel.navigate(to: AnyView(AddItemView(modelContext: modelContext, editingItem: nil, navigationViewModel: navigationViewModel)))
                    }) {
                        Image(systemName: "plus")
                            .font(.title)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .padding()
                }
            }
        }
    }
}

struct ItemPreview: View {
    let item: Item
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(item.title)
                .font(.headline)
            Text(item.itemDescription)
                .font(.subheadline)
                .lineLimit(1)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}
