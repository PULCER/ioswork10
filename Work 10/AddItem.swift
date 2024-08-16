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
    @State private var deletingTaskIndex: Int?
    
    @Environment(\.colorScheme) var colorScheme
    
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
        
        _tasks = State(initialValue: editingItem?.tasks ?? [])
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    styledTextField(title: "Title", text: $title)
                    
                    styledTextEditor(text: $itemDescription)
                    
                    ForEach(links.indices, id: \.self) { index in
                        LinkFieldWithTitle(
                            label: "Link \(index + 1)",
                            link: $links[index].0,
                            title: $links[index].1,
                            onDelete: { deleteLink(at: index) }
                        )
                    }
                    
                    ForEach(tasks.indices, id: \.self) { index in
                        HStack {
                            styledTextField(title: "Task \(index + 1)", text: $tasks[index])
                            
                            Button(action: {
                                deletingTaskIndex = index
                                showingDeleteConfirmation = true
                            }) {
                                Image(systemName: "minus.circle")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .padding()
            }
         
            HStack(spacing: 20) {
                styledButton(title: "Add Link", color: .customBlue, action: addNewLink)
                styledButton(title: "Add Task", color: .customYellow, action: addNewTask)
            }
            .padding(.horizontal)
         
            Spacer()
         
            HStack(spacing: 20) {
                if editingItem != nil {
                    styledButton(title: "Delete", color: .customTeal) {
                        showingDeleteConfirmation = true
                    }
                }
                
                styledButton(title: "Cancel", color: .customPink) {
                    navigationViewModel.goToRoot()
                }
                
                styledButton(title: "Save", color: .customGreen) {
                    saveItem()
                    navigationViewModel.goToRoot()
                }
            }
            .padding()
        }
        .frame(minWidth: 300, idealWidth: 400, maxWidth: .infinity, minHeight: 300, idealHeight: 400, maxHeight: .infinity)
        .navigationTitle(editingItem == nil ? "Add Item" : "Edit Item")
        .alert("Delete Item", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let index = deletingTaskIndex {
                    deleteTask(at: index)
                    deletingTaskIndex = nil
                } else {
                    deleteItem()
                    navigationViewModel.goToRoot()
                }
            }
        } message: {
            Text(deletingTaskIndex != nil ? "Are you sure you want to delete this task?" : "Are you sure you want to delete this item?")
        }
    }

    private func styledTextField(title: String, text: Binding<String>) -> some View {
        TextField(title, text: text)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(colorScheme == .dark ? Color.black : Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.customBlue.opacity(0.5), lineWidth: 1)
            )
    }

    private func styledTextEditor(text: Binding<String>) -> some View {
        TextEditor(text: text)
            .frame(minHeight: 100)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(colorScheme == .dark ? Color.black : Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.customBlue.opacity(0.5), lineWidth: 1)
            )
    }

    private func styledButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
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
                .foregroundColor(.black)
        }
        .buttonStyle(ClickableButtonStyle())
    }

    private func addNewLink() {
        links.append(("", ""))
    }

    private func addNewTask() {
        tasks.append("")
    }

    private func deleteLink(at index: Int) {
        links.remove(at: index)
        saveItem()
    }

    private func deleteTask(at index: Int) {
        tasks.remove(at: index)
        saveItem()
    }

    private func saveItem() {
        let savedLinks = links.compactMap { URL(string: $0.0) }
        let savedLinkTitles = links.map { $0.1 }
        
        if let editingItem = editingItem {
            editingItem.title = title
            editingItem.itemDescription = itemDescription
            editingItem.links = savedLinks
            editingItem.linkTitles = savedLinkTitles
            editingItem.tasks = tasks
        } else {
            let newRank = (try! modelContext.fetch(FetchDescriptor<Item>(sortBy: [SortDescriptor(\.rank, order: .reverse)])).first?.rank ?? 0) + 1
            let newItem = Item(title: title, itemDescription: itemDescription, links: savedLinks, linkTitles: savedLinkTitles, timestamp: Date(), rank: newRank, tasks: tasks)
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
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 10) {
            TextField("\(label) Title", text: $title)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(colorScheme == .dark ? Color.black : Color.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.customBlue.opacity(0.5), lineWidth: 1)
                )
            
            HStack {
                TextField(label, text: $link)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(colorScheme == .dark ? Color.black : Color.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.customBlue.opacity(0.5), lineWidth: 1)
                    )
                
                Button(action: {
                    showingDeleteConfirmation = true
                }) {
                    Image(systemName: "minus.circle")
                        .foregroundColor(.red)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(colorScheme == .dark ? Color.black : Color.white)
                                .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 1)
                        )
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
