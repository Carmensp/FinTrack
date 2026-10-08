import SwiftUI
import CoreData

struct AddBudgetView: View {
    @Environment(\.dismiss) private var dismiss

    @FetchRequest(
        entity: Category.entity(),
        sortDescriptors: [
            NSSortDescriptor(
                key: "name",
                ascending: true
            )
        ]
    )
    private var categories: FetchedResults<Category>

    @StateObject private var viewModel: BudgetsViewModel

    @State private var amountText = ""
    @State private var month = Date()
    @State private var selectedCategory: Category?

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(
            wrappedValue: BudgetsViewModel(
                context: context
            )
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: - Amount

                    VStack(spacing: 8) {
                        Text("¿Cuál es tu límite?")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextField(
                            "0,00 €",
                            text: $amountText
                        )
                        .font(
                            .system(
                                size: 42,
                                weight: .bold
                            )
                        )
                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                        .padding(.vertical, 8)
                    }
                    .frame(maxWidth: .infinity)

                    // MARK: - Details

                    VStack(alignment: .leading, spacing: 10) {
                        Text("DETALLES")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        VStack(spacing: 0) {

                            // Category

                            BudgetCategoryPickerRow(
                                category: selectedCategory
                            ) {
                                CategoryPicker(
                                    categories: categories,
                                    selection: $selectedCategory
                                )
                            }

                            Divider()
                                .padding(.leading, 52)

                            // Month

                            BudgetMonthPickerRow(
                                month: $month
                            )
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(
                                    Color(
                                        .secondarySystemBackground
                                    )
                                )
                        )
                    }

                    // MARK: - Info

                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 10) {
                            Image(systemName: "info.circle")
                                .foregroundStyle(.green)

                            Text("Consejo")
                                .font(.subheadline.weight(.semibold))
                        }

                        Text(
                            "El presupuesto se aplicará a los gastos de la categoría seleccionada durante este mes."
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                Color.green.opacity(0.08)
                            )
                    )

                    // MARK: - Save

                    Button {
                        saveBudget()
                    } label: {
                        Text("Crear presupuesto")
                            .font(
                                .headline.weight(.semibold)
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16)
                    )
                }
                .padding(20)
            }
            .background(
                Color(.systemBackground)
                    .ignoresSafeArea()
            )
            .navigationTitle("Nuevo presupuesto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .topBarLeading
                ) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Save

    private func saveBudget() {
        let normalizedAmount =
            amountText.replacingOccurrences(
                of: ",",
                with: "."
            )

        guard
            let amount = Double(normalizedAmount),
            amount > 0
        else {
            return
        }

        guard let selectedCategory else {
            return
        }

        viewModel.createBudget(
            amount: amount,
            month: month,
            category: selectedCategory
        )

        dismiss()
    }
}

// MARK: - Category Row

private struct BudgetCategoryPickerRow<
    Destination: View
>: View {

    let category: Category?
    let destination: () -> Destination

    private var categoryColor: Color {
        switch category?.name {
        case "Alimentación":
            return .orange
        case "Transporte":
            return .blue
        case "Ocio":
            return .purple
        case "Compras":
            return .pink
        case "Suscripciones":
            return .cyan
        case "Vivienda":
            return .brown
        case "Salud":
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
                    Text("Categoría")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(
                        category?.name
                            ?? "Seleccionar"
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

// MARK: - Month Row

private struct BudgetMonthPickerRow: View {
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
                Text("Mes")
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

// MARK: - Category Picker

private struct CategoryPicker: View {
    let categories: FetchedResults<Category>

    @Binding var selection: Category?

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(categories) { category in
                    Button {
                        selection = category
                        dismiss()
                    } label: {
                        Label(
                            category.name
                                ?? "Categoría",
                            systemImage:
                                category.icon
                                ?? "folder"
                        )
                        .foregroundStyle(.primary)
                    }
                }
            }
            .navigationTitle("Categoría")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
