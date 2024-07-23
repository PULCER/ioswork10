import SwiftUI
import SwiftData

struct AddNotesView: View {
    @ObservedObject var navigationViewModel: NavigationViewModel
    let modelContext: ModelContext
    
    @State private var title: String
    @State private var notesDescription: String
    @State private var links: [(String, String)] = []
    @State private var showingDeleteConfirmation = false
    
    var editingNote: Notes?
    
    init(modelContext: ModelContext, editingNote: Notes? = nil, navigationViewModel: NavigationViewModel) {
        self.modelContext = modelContext
        self.editingNote = editingNote
        self.navigationViewModel = navigationViewModel
        _title = State(initialValue: editingNote?.title ?? "")
        _notesDescription = State(initialValue: editingNote?.notesDescription ?? "")
        
        if let existingLinks = editingNote?.links, let existingTitles = editingNote?.linkTitles {
            _links = State(initialValue: Array(zip(existingLinks.map { $0.absoluteString }, existingTitles)))
        }
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    TextField("Title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextEditor(text: $notesDescription)
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
                }
                .padding()
            }
         
            Button(action: addNewLink) {
                Text("Add Link")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.customBlue)
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }
            .buttonStyle(ClickableButtonStyle())
            .padding(.horizontal)
         
            Spacer()
         
            HStack(spacing: 20) {
                if editingNote != nil {
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
                    navigationViewModel.goBack()
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
                    saveNote()
                    navigationViewModel.goBack()
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
        .navigationTitle(editingNote == nil ? "Add Note" : "Edit Note")
        .alert("Delete Note", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteNote()
                navigationViewModel.goBack()
            }
        } message: {
            Text("Are you sure you want to delete this note?")
        }
    }

    private func addNewLink() {
        links.append(("", ""))
    }

    private func deleteLink(at index: Int) {
        links.remove(at: index)
        saveNote()
    }

    private func saveNote() {
        let savedLinks = links.compactMap { URL(string: $0.0) }
        let savedLinkTitles = links.map { $0.1 }
        
        if let editingNote = editingNote {
            editingNote.title = title
            editingNote.notesDescription = notesDescription
            editingNote.links = savedLinks
            editingNote.linkTitles = savedLinkTitles
            editingNote.timestamp = Date()
        } else {
            let newRank = (try! modelContext.fetch(FetchDescriptor<Notes>(sortBy: [SortDescriptor(\.rank, order: .reverse)])).first?.rank ?? 0) + 1
            let newNote = Notes(title: title, notesDescription: notesDescription, links: savedLinks, linkTitles: savedLinkTitles, timestamp: Date(), rank: newRank)
            modelContext.insert(newNote)
        }
        
        try? modelContext.save()
    }
    
    private func deleteNote() {
        if let noteToDelete = editingNote {
            modelContext.delete(noteToDelete)
            try? modelContext.save()
        }
    }
}
