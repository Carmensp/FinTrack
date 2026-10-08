import SwiftUI
import CoreData

struct TransactionsView: View {

    @Environment(\.managedObjectContext)
    private var context

    @StateObject private var viewModel: TransactionsViewModel

    @State private var searchText = ""
    @State private var selectedFilter = "Todas"
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

            case "Gastos":
                matchesType = transaction.type == "expense"

            case "Ingresos":
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

                    Text("Todas")
                        .tag("Todas")

                    Text("Gastos")
                        .tag("Gastos")

                    Text("Ingresos")
                        .tag("Ingresos")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 12)

                if filteredTransactions.isEmpty {

                    ContentUnavailableView(
                        "No hay transacciones",
                        systemImage: "tray",
                        description: Text(
                            "Todavía no tienes movimientos que mostrar."
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
            .navigationTitle("Transacciones")
            .searchable(
                text: $searchText,
                prompt: "Buscar movimientos"
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
                        : "Transacción"
                )
                .font(
                    .subheadline.weight(.medium)
                )
                .lineLimit(1)

                HStack(spacing: 4) {

                    Text(
                        transaction.category?.name
                        ?? "Sin categoría"
                    )

                    Text("•")

                    Text(
                        transaction.account?.name
                        ?? "Sin cuenta"
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
