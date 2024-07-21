import SwiftUI
import SwiftData

struct TasksView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @ObservedObject var navigationViewModel: NavigationViewModel
    
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
                .font(.headline)
                .padding()
            
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(sortedTasksWithItems, id: \.0) { task, item in
                        Button(action: {
                            navigationViewModel.navigate(to: AnyView(AddItemView(modelContext: modelContext, editingItem: item, navigationViewModel: navigationViewModel)))
                        }) {
                            Text(task)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
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
                    .background(Color.customBlue)
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }
            .buttonStyle(ClickableButtonStyle())
            .padding()
        }
    }
}
