import SwiftUI
import CoreData

struct EditBudgetView: View {
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

    let budget: Budget
    let onSave: () -> Void

    @State private var amountText: String
    @State private var month: Date
    @State private var selectedCategory: Category?

    init(
        context: NSManagedObjectContext,
        budget: Budget,
        onSave: @escaping () -> Void
    ) {
        self.budget = budget
        self.onSave = onSave

        _viewModel = StateObject(
            wrappedValue: BudgetsViewModel(
                context: context
            )
        )

        _amountText = State(
            initialValue: String(
                format: "%.2f",
                budget.amount
            )
        )

        _month = State(
            initialValue: budget.month ?? Date()
        )

        _selectedCategory = State(
            initialValue: budget.category
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

                            Text("Presupuesto")
                                .font(
                                    .subheadline.weight(.semibold)
                                )
                        }

                        Text(
                            "Los cambios se aplicarán al presupuesto de la categoría seleccionada."
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
                        saveChanges()
                    } label: {
                        Text("Guardar cambios")
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
            .navigationTitle("Editar presupuesto")
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

    private func saveChanges() {
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

        viewModel.updateBudget(
            budget,
            amount: amount,
            month: month,
            category: selectedCategory
        )

        onSave()
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
                        category?.name ?? "Seleccionar"
                    )
                    .font(
                        .subheadline.weight(.medium)
                    )
                    .foregroundStyle(.primary)
                }

                Spacer()

                Image(systemName: "chevron.right")
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
                            category.name ?? "Categoría",
                            systemImage:
                                category.icon ?? "folder"
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
