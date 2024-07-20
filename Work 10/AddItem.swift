import SwiftUI
import SwiftData

struct AddItemView: View {
    @ObservedObject var navigationViewModel: NavigationViewModel
    let modelContext: ModelContext
    
    @State private var title: String
    @State private var itemDescription: String
    @State private var linkString: String
    @State private var showingDeleteConfirmation = false
    
    var editingItem: Item?
    
    init(modelContext: ModelContext, editingItem: Item? = nil, navigationViewModel: NavigationViewModel) {
        self.modelContext = modelContext
        self.editingItem = editingItem
        self.navigationViewModel = navigationViewModel
        _title = State(initialValue: editingItem?.title ?? "")
        _itemDescription = State(initialValue: editingItem?.itemDescription ?? "")
        _linkString = State(initialValue: editingItem?.links?.compactMap { $0.absoluteString }.joined(separator: ", ") ?? "")
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
            
            HStack(spacing: 20) {
                if editingItem != nil {
                    Button("Delete") {
                        showingDeleteConfirmation = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.customTeal)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                Button("Cancel") {
                    navigationViewModel.goToRoot()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.customPink)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Save") {
                    saveItem()
                    navigationViewModel.goToRoot()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.customGreen)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
        .frame(minWidth: 300, idealWidth: 400, maxWidth: .infinity, minHeight: 300, idealHeight: 400, maxHeight: .infinity)
        .navigationTitle(editingItem == nil ? "Add Item" : "Edit Item")
        .alert("Delete Item", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteItem()
                navigationViewModel.goToRoot()
            }
        } message: {
            Text("Are you sure you want to delete this item?")
        }
    }

    private func saveItem() {
        let links = linkString.split(separator: ",").compactMap { URL(string: String($0).trimmingCharacters(in: .whitespaces)) }
        
        if let editingItem = editingItem {
            editingItem.title = title
            editingItem.itemDescription = itemDescription
            editingItem.links = links
        } else {
            let newRank = (try! modelContext.fetch(FetchDescriptor<Item>(sortBy: [SortDescriptor(\.rank, order: .reverse)])).first?.rank ?? 0) + 1
            let newItem = Item(title: title, itemDescription: itemDescription, links: links, timestamp: Date(), rank: newRank)
            modelContext.insert(newItem)
        }
        
        try? modelContext.save()
    }
    
    private func deleteItem() {
        if let itemToDelete = editingItem {
            modelContext.delete(itemToDelete)
            try? modelContext.save()
        }
    }
}
