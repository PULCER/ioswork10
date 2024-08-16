import SwiftUI
import SwiftData

struct NotesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Notes.rank) private var notes: [Notes]
    @ObservedObject var navigationViewModel: NavigationViewModel
    
    var body: some View {
        VStack {
            Text("Notes")
                .font(.largeTitle)
                .padding()
            
            ScrollView {
                LazyVStack(spacing: 25) {
                    ForEach(notes) { note in
                        NotePreview(note: note, onMoveUp: {
                            moveNote(note, direction: .up)
                        }, onMoveDown: {
                            moveNote(note, direction: .down)
                        })
                        .onTapGesture {
                            navigationViewModel.navigate(to: AnyView(AddNotesView(modelContext: modelContext, editingNote: note, navigationViewModel: navigationViewModel)))
                        }
                    }
                }
                .padding()
            }
            
            Spacer()
            
            HStack {
                Button(action: {
                    navigationViewModel.goToRoot()
                }) {
                    Text("Back")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.customPink)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
                .buttonStyle(ClickableButtonStyle())
                
                Button(action: {
                    navigationViewModel.navigate(to: AnyView(AddNotesView(modelContext: modelContext, editingNote: nil, navigationViewModel: navigationViewModel)))
                }) {
                    Text("Add Note")
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
    }
    
    private func moveNote(_ note: Notes, direction: MoveDirection) {
        guard let index = notes.firstIndex(of: note) else { return }
        
        switch direction {
        case .up:
            guard index > 0 else { return }
            let newRank = notes[index - 1].rank
            notes[index - 1].rank = note.rank
            note.rank = newRank
        case .down:
            guard index < notes.count - 1 else { return }
            let newRank = notes[index + 1].rank
            notes[index + 1].rank = note.rank
            note.rank = newRank
        }
        
        try? modelContext.save()
    }
}

struct NotePreview: View {
    let note: Notes
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            ArrowButton(direction: .up, action: onMoveUp)
            
            Spacer()
            
            Text(note.title ?? "Untitled Note")
                .font(.headline)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
            
            ArrowButton(direction: .down, action: onMoveDown)
        }
        .frame(height: 60)
        .padding(.horizontal)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(colorScheme == .dark ? Color.black : Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                colorScheme == .dark ? Color.gray.opacity(0.3) : Color.white,
                                colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.customBlue.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: Color.customBlue.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}
