import SwiftUI

internal struct MagnifierValues: Identifiable {
    var id = UUID()

    let value: Double
    let color: GradientColor
}

public struct MultiMagnifierRect: View {
    @Binding var currentNumbers: [MagnifierValues]

    var valueSpecifier: String
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    public var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                ForEach(self.currentNumbers.sorted { $0.value > $1.value }) { number in
                    HStack(alignment: .firstTextBaseline) {
                        Circle()
                            .fill(number.color.start)
                            .frame(width: 14, height: 14)
                        Text("\(number.value, specifier: valueSpecifier)")
                            .fontWeight(.bold)
                            .foregroundColor(self.colorScheme == .dark ? Color.black : Color.white)
                        Spacer()
                    }
                    .frame(maxWidth: 100)
                }
            }
            .padding()
            .foregroundColor(.black)
            .background(Color.white)
            .cornerRadius(20)
            .offset(x: -110, y: CGFloat(-122 + (self.currentNumbers.count * 17))) // 110, 105 x 1, 89 x 2,

            if (self.colorScheme == .dark){
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white, lineWidth: self.colorScheme == .dark ? 2 : 0)
                    .frame(width: 60, height: 260)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .frame(width: 60, height: 280)
                    .foregroundColor(Color.white)
                    .shadow(color: Colors.LegendText, radius: 12, x: 0, y: 6 )
                    .blendMode(.multiply)
            }
        }
    }
}

struct MultiMagnifierRect_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ZStack {
                Rectangle().fill(Color.black)

                MultiMagnifierRect(
                    currentNumbers: .constant([
                        MagnifierValues(value: 20, color: GradientColor(start: .red, end: .red)),
                        MagnifierValues(value: 40, color: GradientColor(start: .blue, end: .blue)),
                        MagnifierValues(value: 2, color: GradientColor(start: .purple, end: .blue)),
                        MagnifierValues(value: 200, color: GradientColor(start: .green, end: .green))
                    ]),
                    valueSpecifier: "%.1f"
                )
                    .opacity(1.0)
                    .offset(x: 0, y: 36)
                    .environment(\.colorScheme, .dark)
            }
        }
    }
}
