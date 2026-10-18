import SwiftUI

struct BudgetMonthPickerRow: View {
    @Binding var month: Date

    var body: some View {
        HStack(spacing: 12) {

            Image(systemName: "calendar")
                .foregroundStyle(.purple)
                .frame(
                    width: 34,
                    height: 34
                )
                .background(
                    Circle()
                        .fill(
                            Color.purple.opacity(0.12)
                        )
                )

            VStack(
                alignment: .leading,
                spacing: 3
            ) {
                Text("Month")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(
                    month,
                    format: .dateTime
                        .month(.wide)
                        .year()
                )
                .font(
                    .subheadline.weight(.medium)
                )
            }

            Spacer()

            DatePicker(
                "",
                selection: $month,
                displayedComponents: .date
            )
            .labelsHidden()
        }
        .padding(14)
    }
}

