import SwiftUI

struct ItemPreview: View {
    let item: Item
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                ArrowButton(direction: .up, action: onMoveUp)
                
                Spacer()
                
                Text(item.title ?? "Untitled")
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                
                Spacer()
                
                ArrowButton(direction: .down, action: onMoveDown)
            }
            .frame(height: 60)
            
            if let links = item.links, let linkTitles = item.linkTitles, !links.isEmpty {
                HStack(spacing: 10) {
                    ForEach(Array(zip(links.prefix(3), linkTitles.prefix(3))), id: \.0) { link, title in
                        Link(destination: link) {
                            Text(title.isEmpty ? "Link \(links.firstIndex(of: link)! + 1)" : title)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(linkColor(for: links.firstIndex(of: link)! + 1))
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
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
    
    private func linkColor(for index: Int) -> Color {
        switch index {
        case 1: return .customPink
        case 2: return .customTeal
        case 3: return .customYellow
        default: return .customGreen
        }
    }
}

struct ArrowButton: View {
    enum Direction {
        case up, down
    }
    
    let direction: Direction
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: direction == .up ? "chevron.up" : "chevron.down")
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color.customBlue)
                .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
