import SwiftUI
import CoreData

struct EditTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var amountFieldFocused: Bool

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
    
    @State private var validationMessage = ""
    @State private var showingValidationAlert = false

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
                        Text("How much?")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextField(
                            "0,00 €",
                            text: $amountText
                        )
                        .font(.system(size: 42, weight: .bold))
                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                        .focused($amountFieldFocused)
                        .padding(.vertical, 8)
                    }
                    .frame(maxWidth: .infinity)

                    // MARK: - Type

                    VStack(alignment: .leading, spacing: 10) {
                        Text("TYPE")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        HStack(spacing: 10) {
                            TransactionTypeButton(
                                title: "Expense",
                                icon: "arrow.down",
                                isSelected: type == "expense",
                                color: .red
                            ) {
                                type = "expense"
                            }

                            TransactionTypeButton(
                                title: "Income",
                                icon: "arrow.up",
                                isSelected: type == "income",
                                color: .green
                            ) {
                                type = "income"
                            }
                        }
                    }
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            amountFieldFocused = false
                        }
                    )

                    // MARK: - Details

                    VStack(alignment: .leading, spacing: 10) {
                        Text("DETAILS")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        VStack(spacing: 0) {
                            FinTrackPickerRow(
                                icon: selectedCategory?.icon ?? "folder",
                                title: "Category",
                                value: selectedCategory?.name ?? "Select",
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
                                title: "Account",
                                value: selectedAccount?.name ?? "Select",
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
                                    Color(.secondarySystemBackground)
                                )
                        )
                    }
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            amountFieldFocused = false
                        }
                    )

                    // MARK: - Note

                    VStack(alignment: .leading, spacing: 10) {
                        Text("NOTE")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        TextField(
                            "Add a note...",
                            text: $note
                        )
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    Color(.secondarySystemBackground)
                                )
                        )
                    }
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            amountFieldFocused = false
                        }
                    )

                    // MARK: - Save

                    Button {
                        amountFieldFocused = false
                        saveChanges()
                    } label: {
                        Text("Save changes")
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
            .scrollDismissesKeyboard(.interactively)
            .background(
                Color(.systemBackground)
                    .ignoresSafeArea()
            )
            .navigationTitle("Edit transaction")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Cannot save transaction", isPresented: $showingValidationAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(validationMessage)
            }
            .toolbar {
                ToolbarItem(
                    placement: .topBarLeading
                ) {
                    Button("Cancel") {
                        amountFieldFocused = false
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Save

    private func saveChanges() {

        // 2. An account must have been selected
        guard let selectedAccount else {
            validationMessage =
                "Select an account to associate with the transaction."
            showingValidationAlert = true
            return
        }

        // 3. The account must have a creation date
        guard let createdAt = selectedAccount.createdAt else {
            validationMessage =
                "The creation date of this account cannot be verified. Review its details before proceeding."
            showingValidationAlert = true
            return
        }

        // 4. The transaction cannot predate the account
        let transactionDay = Calendar.current.startOfDay(for: date)
        let accountCreationDay = Calendar.current.startOfDay(for: createdAt)

        guard transactionDay >= accountCreationDay else {
            validationMessage =
                "The transaction date cannot be earlier than the account creation date (\(createdAt.formatted(date: .abbreviated, time: .omitted)))."
            showingValidationAlert = true
            return
        }

        // 5. Validate the amount
        let normalizedAmount = amountText
            .replacingOccurrences(of: ",", with: ".")

        guard let amount = Double(normalizedAmount), amount > 0 else {
            validationMessage =
                "Enter a valid amount greater than zero."
            showingValidationAlert = true
            return
        }

        // 6. Save only if all validations pass
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

