import SwiftUI

struct TextBoxMod: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(5)
            .border(.black, width: 1)
    }
}

struct Div: View {
    @State var color: Color = Colors.gray2
    @State var colorDark: Color = Colors.gray2Dark
    @Environment(\.colorScheme) var colorScheme
    @State var width: CGFloat = .infinity
    var body: some View {
        Rectangle()
            .frame(maxWidth: width, minHeight: 2, maxHeight: 2)
            .foregroundStyle(colorScheme == .dark ? colorDark : color)
    }
}

struct PlusButton: View {
    @State var action: () -> Void = {}
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        Button(action: action, label: {
            Image(colorScheme == .dark ? "PlusDark" : "Plus")
                .resizable()
                .frame(width: 75, height: 75)
                .padding(10)    
        })
        
    }
}
