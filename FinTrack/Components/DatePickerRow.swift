import SwiftUI

struct DatePickerRow: View {
    @Binding var date: Date

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "calendar")
                .foregroundStyle(.purple)
                .frame(width: 34, height: 34)
                .background(
                    Circle()
                        .fill(Color.purple.opacity(0.12))
                )

            VStack(
                alignment: .leading,
                spacing: 3
            ) {
                Text("Date")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(
                    date,
                    format: .dateTime
                        .day()
                        .month(.wide)
                        .year()
                )
                .font(.subheadline.weight(.medium))
            }

            Spacer()

            DatePicker(
                "",
                selection: $date,
                displayedComponents: .date
            )
            .labelsHidden()
        }
        .padding(14)
    }
}

