import SwiftUI
import SwiftData

struct AddItemView: View {
    @ObservedObject var navigationViewModel: NavigationViewModel
    let modelContext: ModelContext
    
    @State private var title: String
    @State private var itemDescription: String
    @State private var links: [(String, String)] = []
    @State private var tasks: [String] = []
    @State private var showingDeleteConfirmation = false
    
    var editingItem: Item?
    
    init(modelContext: ModelContext, editingItem: Item? = nil, navigationViewModel: NavigationViewModel) {
        self.modelContext = modelContext
        self.editingItem = editingItem
        self.navigationViewModel = navigationViewModel
        _title = State(initialValue: editingItem?.title ?? "")
        _itemDescription = State(initialValue: editingItem?.itemDescription ?? "")
        
        if let existingLinks = editingItem?.links, let existingTitles = editingItem?.linkTitles {
            _links = State(initialValue: Array(zip(existingLinks.map { $0.absoluteString }, existingTitles)))
        }
        
        if let existingTask = editingItem?.task {
            _tasks = State(initialValue: [existingTask])
        }
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    TextField("Title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextEditor(text: $itemDescription)
                        .frame(minHeight: 100)
                        .padding(4)
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
                    
                    ForEach(links.indices, id: \.self) { index in
                        LinkFieldWithTitle(
                            label: "Link \(index + 1)",
                            link: $links[index].0,
                            title: $links[index].1,
                            onDelete: { deleteLink(at: index) }
                        )
                    }
                    
                    ForEach(tasks.indices, id: \.self) { index in
                        TaskField(
                            task: $tasks[index],
                            onDelete: { deleteTask(at: index) }
                        )
                    }
                }
                .padding()
            }
         
            HStack {
                Button(action: addNewLink) {
                    Text("Add Link")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.customBlue)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
                
                Button(action: addNewTask) {
                    Text("Add Task")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.customYellow)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
            }
            .buttonStyle(ClickableButtonStyle())
            .padding(.horizontal)
         
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

    private func addNewLink() {
        links.append(("", ""))
    }

    private func deleteLink(at index: Int) {
        links.remove(at: index)
    }
    
    private func addNewTask() {
        tasks.append("")
    }
    
    private func deleteTask(at index: Int) {
        tasks.remove(at: index)
    }

    private func saveItem() {
        let savedLinks = links.compactMap { URL(string: $0.0) }
        let savedLinkTitles = links.map { $0.1 }
        
        if let editingItem = editingItem {
            editingItem.title = title
            editingItem.itemDescription = itemDescription
            editingItem.links = savedLinks
            editingItem.linkTitles = savedLinkTitles
            editingItem.task = tasks.first
        } else {
            let newRank = (try! modelContext.fetch(FetchDescriptor<Item>(sortBy: [SortDescriptor(\.rank, order: .reverse)])).first?.rank ?? 0) + 1
            let newItem = Item(title: title, itemDescription: itemDescription, links: savedLinks, linkTitles: savedLinkTitles, timestamp: Date(), rank: newRank, task: tasks.first)
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

struct LinkFieldWithTitle: View {
    let label: String
    @Binding var link: String
    @Binding var title: String
    let onDelete: () -> Void
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        VStack(spacing: 10) {
            TextField("\(label) Title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
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
                        onDelete()
                    }
                } message: {
                    Text("Are you sure you want to delete this link and its title?")
                }
            }
        }
    }
}

struct TaskField: View {
    @Binding var task: String
    let onDelete: () -> Void
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        HStack {
            TextField("Task", text: $task)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                showingDeleteConfirmation = true
            }) {
                Image(systemName: "minus.circle")
                    .foregroundColor(.red)
            }
            .alert("Delete Task", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    onDelete()
                }
            } message: {
                Text("Are you sure you want to delete this task?")
            }
        }
    }
}
