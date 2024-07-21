import SwiftUI
import Foundation
import SwiftData

struct TasksView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @ObservedObject var navigationViewModel: NavigationViewModel
    
    var tasks: [(Item, String)] {
        items.compactMap { item in
            if let task = item.task {
                return (item, task)
            }
            return nil
        }
    }
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(Array(tasks.enumerated()), id: \.element.0.id) { index, task in
                        TaskPreview(task: task.1, onMoveUp: {
                            moveTask(at: index, direction: .up)
                        }, onMoveDown: {
                            moveTask(at: index, direction: .down)
                        })
                    }
                }
                .padding()
            }
            
            Button(action: {
                navigationViewModel.goToRoot()
            }) {
                Text("Back")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.customBlue)
                    .cornerRadius(10)
            }
            .buttonStyle(ClickableButtonStyle())
            .padding()
        }
        .navigationTitle("Tasks")
    }
    
    private func moveTask(at index: Int, direction: MoveDirection) {
        guard index >= 0 && index < tasks.count else { return }
        
        switch direction {
        case .up:
            guard index > 0 else { return }
            let temp = tasks[index - 1].0.task
            tasks[index - 1].0.task = tasks[index].0.task
            tasks[index].0.task = temp
        case .down:
            guard index < tasks.count - 1 else { return }
            let temp = tasks[index + 1].0.task
            tasks[index + 1].0.task = tasks[index].0.task
            tasks[index].0.task = temp
        }
        
        try? modelContext.save()
    }
}

struct TaskPreview: View {
    let task: String
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onMoveUp) {
                Image(systemName: "arrow.up")
            }
            .frame(width: 44)
            
            Text(task)
                .font(.body)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: onMoveDown) {
                Image(systemName: "arrow.down")
            }
            .frame(width: 44)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}
