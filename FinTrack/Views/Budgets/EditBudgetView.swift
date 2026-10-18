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
                        Text("What is your limit?")
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
                        Text("DETAILS")
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

                            Text("Budget")
                                .font(
                                    .subheadline.weight(.semibold)
                                )
                        }

                        Text(
                            "The changes will be applied to the budget of the selected category."
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                        .frame(maxWidth: .infinity)
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
                        Text("Save changes")
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
            .navigationTitle("Edit budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .topBarLeading
                ) {
                    Button("Cancel") {
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
