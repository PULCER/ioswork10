import SwiftUI

class NavigationViewModel: ObservableObject {
    @Published var currentView: AnyView?
    @Published var navigationStack: [AnyView] = []
    
    func navigate(to view: AnyView) {
        navigationStack.append(currentView ?? AnyView(EmptyView()))
        currentView = view
    }
    
    func goBack() {
        if !navigationStack.isEmpty {
            currentView = navigationStack.popLast()
        } else {
            currentView = nil
        }
    }
    
    func goToRoot() {
        navigationStack.removeAll()
        currentView = nil
    }
}
