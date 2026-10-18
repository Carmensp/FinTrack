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

                            Text("Advice")
                                .font(.subheadline.weight(.semibold))
                        }

                        Text(
                            "The budget will be applied to expenses in the selected category during this month."
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
                        saveBudget()
                    } label: {
                        Text("Create budget")
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
            .navigationTitle("New budget")
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
