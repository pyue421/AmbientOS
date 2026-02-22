import SwiftUI

struct LabeledSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double> //defines the minimum and maximum values the slider can take

    var body: some View {
        VStack(alignment: .leading, spacing: 4) { //vertical stack
            HStack {
                Text(title)
                    .font(.subheadline)
                Spacer()
                Text(value.formatted(.number.precision(.fractionLength(2))))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Slider(value: $value, in: range)
        }
    }
}
