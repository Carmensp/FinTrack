import SwiftUI

struct TransactionTypeButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)

                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(
                isSelected ? color : .secondary
            )
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        isSelected
                            ? color.opacity(0.12)
                            : Color(.secondarySystemBackground)
                    )
            )
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected
                            ? color.opacity(0.35)
                            : .clear,
                        lineWidth: 1
                    )
            }
        }
        .buttonStyle(.plain)
    }
}

