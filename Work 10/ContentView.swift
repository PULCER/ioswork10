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


struct AddItemView: View {
    @ObservedObject var navigationViewModel: NavigationViewModel
    let modelContext: ModelContext
    
    @State private var title: String
    @State private var itemDescription: String
    @State private var linkString: String
    
    var editingItem: Item?
    
    init(modelContext: ModelContext, editingItem: Item? = nil, navigationViewModel: NavigationViewModel) {
        self.modelContext = modelContext
        self.editingItem = editingItem
        self.navigationViewModel = navigationViewModel
        _title = State(initialValue: editingItem?.title ?? "")
        _itemDescription = State(initialValue: editingItem?.itemDescription ?? "")
        _linkString = State(initialValue: editingItem?.links.map { $0.absoluteString }.joined(separator: ", ") ?? "")
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    TextField("Title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Description", text: $itemDescription)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Links (comma-separated)", text: $linkString)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
            }
            
            Spacer()
            
            HStack {
                Button("Cancel") {
                    navigationViewModel.goToRoot()
                }
                .frame(maxWidth: .infinity)
                
                Button("Save") {
                    saveItem()
                    navigationViewModel.goToRoot()
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
        }
        .frame(minWidth: 300, idealWidth: 400, maxWidth: .infinity, minHeight: 300, idealHeight: 400, maxHeight: .infinity)
        .navigationTitle(editingItem == nil ? "Add Item" : "Edit Item")
    }
    
    private func saveItem() {
        let links = linkString.split(separator: ",").compactMap { URL(string: String($0).trimmingCharacters(in: .whitespaces)) }
        
        if let editingItem = editingItem {
            editingItem.title = title
            editingItem.itemDescription = itemDescription
            editingItem.links = links
        } else {
            let newItem = Item(title: title, itemDescription: itemDescription, links: links, timestamp: Date())
            modelContext.insert(newItem)
        }
        
        try? modelContext.save()
    }
}
