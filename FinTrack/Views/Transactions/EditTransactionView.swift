import SwiftUI
import CoreData

struct EditTransactionView: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: () -> Void

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \Category.name,
                ascending: true
            )
        ]
    )
    private var categories: FetchedResults<Category>

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \Account.name,
                ascending: true
            )
        ]
    )
    private var accounts: FetchedResults<Account>

    @StateObject private var viewModel: TransactionsViewModel

    private let transaction: Transaction

    @State private var amountText: String
    @State private var type: String
    @State private var date: Date
    @State private var note: String

    @State private var selectedCategory: Category?
    @State private var selectedAccount: Account?

    init(
        context: NSManagedObjectContext,
        transaction: Transaction,
        onSave: @escaping () -> Void
    ) {
        self.transaction = transaction
        self.onSave = onSave

        _viewModel = StateObject(
            wrappedValue: TransactionsViewModel(
                context: context
            )
        )

        _amountText = State(
            initialValue: String(
                format: "%.2f",
                transaction.amount
            )
        )

        _type = State(
            initialValue: transaction.type ?? "expense"
        )

        _date = State(
            initialValue: transaction.date ?? Date()
        )

        _note = State(
            initialValue: transaction.note ?? ""
        )

        _selectedCategory = State(
            initialValue: transaction.category
        )

        _selectedAccount = State(
            initialValue: transaction.account
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: - Amount

                    VStack(spacing: 8) {
                        Text("¿Cuánto?")
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

                    // MARK: - Type

                    VStack(alignment: .leading, spacing: 10) {
                        Text("TIPO")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        HStack(spacing: 10) {
                            TransactionTypeButton(
                                title: "Gasto",
                                icon: "arrow.down",
                                isSelected: type == "expense",
                                color: .red
                            ) {
                                type = "expense"
                            }

                            TransactionTypeButton(
                                title: "Ingreso",
                                icon: "arrow.up",
                                isSelected: type == "income",
                                color: .green
                            ) {
                                type = "income"
                            }
                        }
                    }

                    // MARK: - Details

                    VStack(alignment: .leading, spacing: 10) {
                        Text("DETALLES")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        VStack(spacing: 0) {

                            FinTrackPickerRow(
                                icon: selectedCategory?.icon ?? "folder",
                                title: "Categoría",
                                value: selectedCategory?.name ?? "Seleccionar",
                                color: .orange
                            ) {
                                CategoryPicker(
                                    categories: categories,
                                    selection: $selectedCategory
                                )
                            }

                            Divider()
                                .padding(.leading, 52)

                            FinTrackPickerRow(
                                icon: selectedAccount?.icon ?? "building.columns",
                                title: "Cuenta",
                                value: selectedAccount?.name ?? "Seleccionar",
                                color: .blue
                            ) {
                                AccountPicker(
                                    accounts: accounts,
                                    selection: $selectedAccount
                                )
                            }

                            Divider()
                                .padding(.leading, 52)

                            DatePickerRow(date: $date)
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

                    // MARK: - Note

                    VStack(alignment: .leading, spacing: 10) {
                        Text("NOTA")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        TextField(
                            "Añade una nota...",
                            text: $note
                        )
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    Color(
                                        .secondarySystemBackground
                                    )
                                )
                        )
                    }

                    // MARK: - Save

                    Button {
                        saveChanges()
                    } label: {
                        Text("Guardar cambios")
                            .font(.headline.weight(.semibold))
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
            .navigationTitle("Editar transacción")
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

        viewModel.updateTransaction(
            transaction,
            amount: amount,
            date: date,
            note: note,
            type: type,
            category: selectedCategory,
            account: selectedAccount
        )

        onSave()
        dismiss()
    }
}

// MARK: - Transaction Type Button

private struct TransactionTypeButton: View {
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
                isSelected
                    ? color
                    : .secondary
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

// MARK: - Account Picker

private struct AccountPicker: View {
    let accounts: FetchedResults<Account>

    @Binding var selection: Account?

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(accounts) { account in
                    Button {
                        selection = account
                        dismiss()
                    } label: {
                        Label(
                            account.name ?? "Cuenta",
                            systemImage:
                                account.icon
                                ?? "building.columns"
                        )
                        .foregroundStyle(.primary)
                    }
                }
            }
            .navigationTitle("Cuenta")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Picker Row

private struct FinTrackPickerRow<Destination: View>: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let destination: () -> Destination

    var body: some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .frame(
                        width: 34,
                        height: 34
                    )
                    .background(
                        Circle()
                            .fill(color.opacity(0.12))
                    )

                VStack(
                    alignment: .leading,
                    spacing: 3
                ) {
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(value)
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

// MARK: - Date Row

private struct DatePickerRow: View {
    @Binding var date: Date

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
                Text("Fecha")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(
                    date,
                    format: .dateTime
                        .day()
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
                selection: $date,
                displayedComponents: .date
            )
            .labelsHidden()
        }
        .padding(14)
    }
}
