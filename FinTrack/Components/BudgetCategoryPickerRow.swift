import SwiftUI
import CoreData

struct BudgetCategoryPickerRow<
    Destination: View
    >: View {

    let category: Category?
    let destination: () -> Destination

    private var categoryColor: Color {
        switch category?.name {
        case "Feeding":
            return .orange
        case "Transport":
            return .blue
        case "Leisure":
            return .purple
        case "Shopping":
            return .pink
        case "Subscriptions":
            return .cyan
        case "House":
            return .brown
        case "Health":
            return .red
        default:
            return .gray
        }
    }

    var body: some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: 12) {

                Image(
                    systemName:
                        category?.icon ?? "folder"
                )
                .foregroundStyle(categoryColor)
                .frame(
                    width: 34,
                    height: 34
                )
                .background(
                    Circle()
                        .fill(
                            categoryColor.opacity(0.12)
                        )
                )

                VStack(
                    alignment: .leading,
                    spacing: 3
                ) {
                    Text("Category")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(
                        category?.name
                            ?? "Select"
                    )
                    .font(
                        .subheadline.weight(.medium)
                    )
                    .foregroundStyle(.primary)
                }

                Spacer()

                Image(
                    systemName: "chevron.right"
                )
                .font(
                    .caption.weight(.semibold)
                )
                .foregroundStyle(.tertiary)
            }
            .padding(14)
        }
        .buttonStyle(.plain)
    }
}
