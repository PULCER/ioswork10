import SwiftUI
import SwiftData

struct AddItemView: View {
    @ObservedObject var navigationViewModel: NavigationViewModel
    let modelContext: ModelContext
    
    @State private var title: String
    @State private var itemDescription: String
    @State private var link1: String = ""
    @State private var link2: String = ""
    @State private var link3: String = ""
    @State private var showingDeleteConfirmation = false
    
    var editingItem: Item?
    
    init(modelContext: ModelContext, editingItem: Item? = nil, navigationViewModel: NavigationViewModel) {
        self.modelContext = modelContext
        self.editingItem = editingItem
        self.navigationViewModel = navigationViewModel
        _title = State(initialValue: editingItem?.title ?? "")
        _itemDescription = State(initialValue: editingItem?.itemDescription ?? "")
        
        if let links = editingItem?.links, !links.isEmpty {
            _link1 = State(initialValue: links[0].absoluteString)
            _link2 = State(initialValue: links.count > 1 ? links[1].absoluteString : "")
            _link3 = State(initialValue: links.count > 2 ? links[2].absoluteString : "")
        }
    }
    
    @State private var isDescriptionEmpty: Bool = true

       var body: some View {
           VStack {
               ScrollView {
                   VStack(spacing: 20) {
                       TextField("Title", text: $title)
                           .textFieldStyle(RoundedBorderTextFieldStyle())
                       
                       ZStack(alignment: .topLeading) {
                           TextEditor(text: $itemDescription)
                               .frame(minHeight: 100)
                               .padding(4)
                               .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
                               .onChange(of: itemDescription) { newValue in
                                   isDescriptionEmpty = newValue.isEmpty
                               }
                           
                           if isDescriptionEmpty {
                               Text("Enter description here...")
                                   .foregroundColor(.gray.opacity(0.8))
                                   .padding(.horizontal, 8)
                                   .padding(.vertical, 12)
                                   .allowsHitTesting(false)
                           }
                       }
                       
                       LinkField(label: "Link 1", link: $link1)
                       LinkField(label: "Link 2", link: $link2)
                       LinkField(label: "Link 3", link: $link3)
                   }
                   .padding()
               }
            
            Spacer()
            
               HStack(spacing: 20) {
                             if editingItem != nil {
                                 Button(action: {
                                     showingDeleteConfirmation = true
                                 }) {
                                     Text("Delete")
                                         .frame(maxWidth: .infinity)
                                         .padding()
                                         .background(Color.customTeal)
                                         .foregroundColor(.black)
                                         .cornerRadius(10)
                                 }
                                 .buttonStyle(ClickableButtonStyle())
                             }
                             
                             Button(action: {
                                 navigationViewModel.goToRoot()
                             }) {
                                 Text("Cancel")
                                     .frame(maxWidth: .infinity)
                                     .padding()
                                     .background(Color.customPink)
                                     .foregroundColor(.black)
                                     .cornerRadius(10)
                             }
                             .buttonStyle(ClickableButtonStyle())
                             
                             Button(action: {
                                 saveItem()
                                 navigationViewModel.goToRoot()
                             }) {
                                 Text("Save")
                                     .frame(maxWidth: .infinity)
                                     .padding()
                                     .background(Color.customGreen)
                                     .foregroundColor(.black)
                                     .cornerRadius(10)
                             }
                             .buttonStyle(ClickableButtonStyle())
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
        let links = [link1, link2, link3]
            .filter { !$0.isEmpty }
            .compactMap { URL(string: $0) }
        
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

struct LinkField: View {
    let label: String
    @Binding var link: String
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        HStack {
            TextField(label, text: $link)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                showingDeleteConfirmation = true
            }) {
                Image(systemName: "minus.circle")
                    .foregroundColor(.red)
            }
            .alert("Delete Link", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    link = ""
                }
            } message: {
                Text("Are you sure you want to delete this link?")
            }
        }
    }
}
