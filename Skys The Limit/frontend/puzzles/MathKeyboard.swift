import SwiftUI

// MARK: - Key Types
enum KeyType {
    case character
    case backspace
}

// MARK: - Math Key
struct MathKey: Identifiable, Hashable {
    let id = UUID()
    let display: String
    let mathValue: String
    let type: KeyType
}

// MARK: - Math Keyboard View
struct MathKeyboardView: View {
    @Binding var latexString: String
    @Binding var mathString: String
    
    private let keyboardRows: [[MathKey]] = [
        [
            MathKey(display: "1", mathValue: "1", type: .character),
            MathKey(display: "2", mathValue: "2", type: .character),
            MathKey(display: "3", mathValue: "3", type: .character)
        ],
        [
            MathKey(display: "4", mathValue: "4", type: .character),
            MathKey(display: "5", mathValue: "5", type: .character),
            MathKey(display: "6", mathValue: "6", type: .character),
            MathKey(display: "x", mathValue: "x", type: .character),
            MathKey(display: "y", mathValue: "y", type: .character)
        ],
        [
            MathKey(display: "7", mathValue: "7", type: .character),
            MathKey(display: "8", mathValue: "8", type: .character),
            MathKey(display: "9", mathValue: "9", type: .character),
            MathKey(display: "0", mathValue: "0", type: .character),
            MathKey(display: ".", mathValue: ".", type: .character),
            MathKey(display: "/", mathValue: "/", type: .character)
        ],
        [
            MathKey(display: "x²", mathValue: "^2", type: .character),
            MathKey(display: "√", mathValue: "sqrt(", type: .character),
            MathKey(display: "⌫", mathValue: "", type: .backspace),
            MathKey(display: "+", mathValue: "+", type: .character),
            MathKey(display: "-", mathValue: "-", type: .character),
            MathKey(display: "=", mathValue: "=", type: .character),
            MathKey(display: "<", mathValue: "<", type: .character),
            MathKey(display: ">", mathValue: ">", type: .character),
            MathKey(display: "{", mathValue: "{", type: .character),
            MathKey(display: "}", mathValue: "}", type: .character)
        ]
    ]
    
    var body: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 8
            let maxKeysInRow = keyboardRows.map { $0.count }.max() ?? 1
            let totalSpacing = spacing * CGFloat(maxKeysInRow - 1)
            let keyWidth = (geo.size.width - totalSpacing - 24) / CGFloat(maxKeysInRow)
            
            VStack(spacing: spacing) {
                ForEach(keyboardRows, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(row) { key in
                            Button(action: { handleKeyPress(key) }) {
                                Text(key.display)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(key.type == .backspace ? .white : .primary.opacity(0.9))
                                    .frame(width: keyWidth, height: 56)
                                    .background(
                                        ZStack {
                                            // Liquid glass effect
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: key.type == .backspace ? [Color.red.opacity(0.9), Color.red.opacity(0.6)] : [Color.white.opacity(0.25), Color.white.opacity(0.05)]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .background(.ultraThinMaterial)
                                                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                            
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        }
                                    )
                                    .contentShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .accessibilityLabel(accessibilityLabel(for: key))
                        }
                        if row.count < maxKeysInRow {
                            ForEach(0..<(maxKeysInRow - row.count), id: \.self) { _ in
                                Spacer()
                                    .frame(width: keyWidth)
                            }
                        }
                    }
                }
            }
            .padding(12)
            .background(.ultraThinMaterial)
            .cornerRadius(24)
            .padding(.horizontal, 12)
        }
        .frame(height: 260)
    }
    
    private func handleKeyPress(_ key: MathKey) {
        switch key.type {
        case .character:
            latexString += key.display
            mathString += key.mathValue
        case .backspace:
            if !latexString.isEmpty { latexString.removeLast() }
            if !mathString.isEmpty { mathString.removeLast() }
        }
    }
    
    private func accessibilityLabel(for key: MathKey) -> String {
        switch key.type {
        case .backspace: return "Backspace"
        case .character: return key.display
        }
    }
}
