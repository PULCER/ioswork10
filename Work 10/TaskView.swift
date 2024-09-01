import SwiftUI
import SwiftData

struct TasksView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @ObservedObject var navigationViewModel: NavigationViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var sortedTasksWithItems: [(String, Item)] {
        let allTasks = items.flatMap { item in
            (item.tasks ?? []).map { task in
                (task, item)
            }
        }
        
        return allTasks.sorted { (task1, task2) in
            let components1 = task1.0.components(separatedBy: CharacterSet.decimalDigits.inverted)
            let components2 = task2.0.components(separatedBy: CharacterSet.decimalDigits.inverted)
            
            if let number1 = Int(components1.first ?? ""), let number2 = Int(components2.first ?? "") {
                if number1 != number2 {
                    return number1 < number2
                }
            }
            
            return task1.0.localizedStandardCompare(task2.0) == .orderedAscending
        }
    }
    
    var body: some View {
        VStack {
            Text("All Tasks")
                .font(.largeTitle)
                .padding()
            
            ScrollView {
                LazyVStack(spacing: 25) {
                    ForEach(sortedTasksWithItems, id: \.0) { task, item in
                        TaskPreview(task: task)
                            .onTapGesture {
                                navigationViewModel.navigate(to: AnyView(AddItemView(modelContext: modelContext, editingItem: item, navigationViewModel: navigationViewModel)))
                            }
                    }
                }
                .padding()
            }
            
            Spacer()
            
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
            .padding()
        }
    }
}

struct TaskPreview: View {
    let task: String
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Text(task)
                .font(.headline)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .center)
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
