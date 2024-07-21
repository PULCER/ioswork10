import SwiftUI
import SwiftData

struct TasksView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @ObservedObject var navigationViewModel: NavigationViewModel
    
    var allTasks: [String] {
        items.flatMap { $0.tasks ?? [] }
    }
    
    var body: some View {
        VStack {
            Text("All Tasks")
                .font(.headline)
                .padding()
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(allTasks, id: \.self) { task in
                        Text(task)
                            .padding(.horizontal)
                    }
                }
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
