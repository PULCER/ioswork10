import SwiftUI
import SwiftData

struct TasksView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @ObservedObject var navigationViewModel: NavigationViewModel
    
    var allTasksWithItems: [(String, Item)] {
        items.flatMap { item in
            (item.tasks ?? []).map { task in
                (task, item)
            }
        }
    }
    
    var body: some View {
        VStack {
            Text("All Tasks")
                .font(.headline)
                .padding()
            
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(allTasksWithItems, id: \.0) { task, item in
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
