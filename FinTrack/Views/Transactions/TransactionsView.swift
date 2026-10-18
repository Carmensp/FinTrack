import SwiftUI
import CoreData

struct TransactionsView: View {

    @Environment(\.managedObjectContext)
    private var context

    @StateObject private var viewModel: TransactionsViewModel

    @State private var searchText = ""
    @State private var selectedFilter = "All"
    @State private var showingAddTransaction = false
    @State private var transactionToEdit: Transaction?

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(
            wrappedValue: TransactionsViewModel(
                context: context
            )
        )
    }

    private var filteredTransactions: [Transaction] {

        viewModel.transactions.filter { transaction in

            let matchesType: Bool

            switch selectedFilter {

            case "Expenses":
                matchesType = transaction.type == "expense"

            case "Incomes":
                matchesType = transaction.type == "income"

            default:
                matchesType = true
            }

            let note = transaction.note ?? ""

            let matchesSearch =
                searchText.isEmpty ||
                note.localizedCaseInsensitiveContains(
                    searchText
                ) ||
                (transaction.category?.name ?? "")
                    .localizedCaseInsensitiveContains(
                        searchText
                    ) ||
                (transaction.account?.name ?? "")
                    .localizedCaseInsensitiveContains(
                        searchText
                    )

            return matchesType && matchesSearch
        }
    }

    var body: some View {

        NavigationStack {

            VStack(spacing: 0) {

                Picker(
                    "Filter",
                    selection: $selectedFilter
                ) {

                    Text("All")
                        .tag("All")

                    Text("Expenses")
                        .tag("Expenses")

                    Text("Incomes")
                        .tag("Incomes")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 12)

                if filteredTransactions.isEmpty {

                    ContentUnavailableView(
                        "There is no transactions",
                        systemImage: "tray",
                        description: Text(
                            "You don't have any transactions to show yet."
                        )
                    )

                } else {

                    List {
                        ForEach(filteredTransactions) { transaction in
                            TransactionRow(transaction: transaction)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    transactionToEdit = transaction
                                }
                        }
                        .onDelete(perform: deleteTransactions)
                    }
                    .id(viewModel.refreshID)
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Transactions")
            .searchable(
                text: $searchText,
                prompt: "Search for movements"
            )
            .toolbar {

                ToolbarItem(
                    placement: .topBarTrailing
                ) {

                    Button {

                        showingAddTransaction = true

                    } label: {

                        Image(
                            systemName: "plus"
                        )
                    }
                }
            }

            // MARK: - Add Transaction

            .sheet(
                isPresented: $showingAddTransaction
            ) {

                AddTransactionView(
                    context: context
                )
                .onDisappear {

                    viewModel.fetchTransactions()
                }
            }

            // MARK: - Edit Transaction

            .sheet(
                item: $transactionToEdit
            ) { transaction in

                EditTransactionView(
                    context: context,
                    transaction: transaction
                ) {
                    viewModel.fetchTransactions()
                }
            }
        }
        .onAppear {

            viewModel.fetchTransactions()
        }
    }

    private func deleteTransactions(
        at offsets: IndexSet
    ) {

        let transactionsToDelete =
            offsets.map {
                filteredTransactions[$0]
            }

        for transaction in transactionsToDelete {

            viewModel.deleteTransaction(
                transaction
            )
        }
    }
}

private struct TransactionRow: View {

    let transaction: Transaction

    private var isIncome: Bool {
        transaction.type == "income"
    }

    private var displayAmount: Double {
        isIncome
            ? transaction.amount
            : -transaction.amount
    }

    var body: some View {

        HStack(spacing: 12) {

            Image(
                systemName:
                    transaction.category?.icon
                    ?? "arrow.left.arrow.right"
            )
            .font(.subheadline)
            .frame(
                width: 42,
                height: 42
            )
            .background(
                Circle()
                    .fill(
                        isIncome
                            ? Color.green.opacity(0.15)
                            : Color(.secondarySystemBackground)
                    )
            )

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text(
                    transaction.note?.isEmpty == false
                        ? transaction.note!
                        : "Transaction"
                )
                .font(
                    .subheadline.weight(.medium)
                )
                .lineLimit(1)

                HStack(spacing: 4) {

                    Text(
                        transaction.category?.name
                        ?? "Ungategorized"
                    )

                    Text("•")

                    Text(
                        transaction.account?.name
                        ?? "Without an account"
                    )
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

                if let date = transaction.date {

                    Text(
                        date,
                        style: .date
                    )
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(
                displayAmount,
                format: .currency(
                    code: "EUR"
                )
            )
            .font(
                .subheadline.weight(.semibold)
            )
            .foregroundStyle(
                isIncome
                    ? .green
                    : .primary
            )
        }
        .padding(.vertical, 6)
    }
}
