import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var showingAddItemView = false
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack {
                    ForEach(items) { item in
                        NavigationLink(destination: ItemRow(item: item)) {
                            ItemPreview(item: item)
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
                        showingAddItemView = true
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
        .navigationTitle("Items")
        .sheet(isPresented: $showingAddItemView) {
            AddItemView(modelContext: modelContext)
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
            Text("Links: \(item.links.count)")
                .font(.caption)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct ItemRow: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var item: Item
    
    @State private var title: String
    @State private var itemDescription: String
    @State private var linkString: String
    
    init(item: Item) {
        self.item = item
        _title = State(initialValue: item.title)
        _itemDescription = State(initialValue: item.itemDescription)
        _linkString = State(initialValue: item.links.map { $0.absoluteString }.joined(separator: ", "))
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
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                
                Button("Save") {
                    saveItem()
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
        }
        .navigationTitle("Edit Item")
    }
    
    private func saveItem() {
        item.title = title
        item.itemDescription = itemDescription
        item.links = linkString.split(separator: ",").compactMap { URL(string: String($0).trimmingCharacters(in: .whitespaces)) }
        try? modelContext.save()
        dismiss()
    }
}

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    let modelContext: ModelContext
    
    @State private var title = ""
    @State private var itemDescription = ""
    @State private var linkString = ""
    
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
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                
                Button("Save") {
                    saveItem()
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
        }
        .navigationTitle("Add Item")
    }
    
    private func saveItem() {
        let links = linkString.split(separator: ",").compactMap { URL(string: String($0).trimmingCharacters(in: .whitespaces)) }
        let newItem = Item(title: title, itemDescription: itemDescription, links: links, timestamp: Date())
        modelContext.insert(newItem)
        dismiss()
    }
}
