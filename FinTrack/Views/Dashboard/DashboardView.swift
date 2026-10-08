
import SwiftUI
import CoreData

struct DashboardView: View {
    
    @Environment(\.managedObjectContext)
    private var context

    @StateObject private var viewModel: DashboardViewModel
    @State private var showingAddTransaction = false
    @State private var selectedPeriod: DashboardPeriod = .month
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(
            wrappedValue: DashboardViewModel(
                context: context
            )
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {

                VStack(alignment: .leading, spacing: 20) {

                    // Greeting
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hola de nuevo! ✨")
                            .font(.title2.weight(.bold))

//                        HStack(spacing: 5) {
//                            Circle()
//                                .fill(.green)
//                                .frame(width: 6, height: 6)
//
//                            Text("Sincronizado hace 2 min")
//                                .font(.caption)
//                                .foregroundStyle(.secondary)
//                        }
                    }

                    // Period selector
                    Picker("Periodo", selection: $selectedPeriod) {
                        Text("Este mes")
                            .tag(DashboardPeriod.month)

                        Text("Semana")
                            .tag(DashboardPeriod.week)

                        Text("Año")
                            .tag(DashboardPeriod.year)

                        Text("Total")
                            .tag(DashboardPeriod.total)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedPeriod) { _, newValue in
                        viewModel.loadDashboard(period: newValue)
                    }
                    
                    // Net worth
                    NetWorthCard(
                        netWorth: viewModel.netWorth,
                        income: viewModel.totalIncome,
                        expenses: viewModel.totalExpenses,
                        savings: viewModel.savings
                    )

                    // Quick actions
                    QuickActionsView {
                        showingAddTransaction = true
                    }
                    
                    DashboardChartCard(
                        income: viewModel.totalIncome,
                        expenses: viewModel.totalExpenses
                    )
                    
                    NavigationLink {
                        AnalyticsView(context: context)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Ver análisis")
                                    .font(.headline)

                                Text("Consulta gráficos detallados de tus finanzas")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.secondarySystemBackground))
                        )
                    }
                    .buttonStyle(.plain)

                    // Placeholder
                    AccountsSection(
                        accounts: viewModel.accounts
                    )

                    // Placeholder
                    RecentTransactionsSection(
                        transactions: viewModel.recentTransactions
                    )
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .navigationTitle("FinTrack")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadDashboard(period: .month)
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView(context: context)
                    .onDisappear {
                        viewModel.loadDashboard()
                    }
            }
        }
    }
}



private struct QuickActionsView: View {
    
    @Environment(\.managedObjectContext)
    private var context

    let onAddTransaction: () -> Void

    var body: some View {
        HStack(spacing: 12) {

            Button {
                onAddTransaction()
            } label: {
                QuickAction(
                    icon: "plus",
                    title: "Ingreso/Gasto"
                )
            }

            NavigationLink {
                TransactionsView(context: context)
            } label: {
                QuickAction(
                    icon: "arrow.left.arrow.right",
                    title: "Transacciones"
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                BudgetsView(context: context)
            } label: {
                QuickAction(
                    icon: "chart.bar",
                    title: "Presupuestos"
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                AccountsView(context: context)
            } label: {
                QuickAction(
                    icon: "chart.xyaxis.line",
                    title: "Cuentas"
                )
            }
            .buttonStyle(.plain)
        }
    }
}

private struct QuickAction: View {

    let icon: String
    let title: String

    var body: some View {
        VStack(spacing: 8) {

            Image(systemName: icon)
                .font(.title3)
                .frame(width: 48, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.secondarySystemBackground))
                )

            Text(title)
                .font(.caption2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

//private struct CashFlowPlaceholder: View {
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//
//            Text("Flujo de Caja")
//                .font(.headline)
//
//            Text("Evolución semanal • Noviembre")
//                .font(.caption)
//                .foregroundStyle(.secondary)
//
//            RoundedRectangle(cornerRadius: 16)
//                .fill(Color(.secondarySystemBackground))
//                .frame(height: 180)
//                .overlay {
//                    Text("Aquí irá Swift Charts")
//                        .foregroundStyle(.secondary)
//                }
//        }
//    }
//}

private struct AccountsSection: View {

    let accounts: [Account]

    var body: some View {

        VStack(alignment: .leading, spacing: 12) {

            HStack {

                Text("Tus Cuentas")
                    .font(.headline)

                Spacer()

//                Button("Ver todas") {
//                }
//                .font(.caption)
            }

            ScrollView(
                .horizontal,
                showsIndicators: false
            ) {

                HStack(spacing: 12) {

                    ForEach(accounts) { account in

                        AccountCard(
                            account: account
                        )
                    }
                }
            }
        }
    }
}

private struct AccountCard: View {

    let account: Account

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            HStack {

                Image(
                    systemName:
                        account.icon
                        ?? "building.columns"
                )
                .font(.subheadline)
                .frame(
                    width: 34,
                    height: 34
                )
                .background(
                    Circle()
                        .fill(
                            Color(.systemBackground)
                        )
                )

                Spacer()

                Image(
                    systemName: "ellipsis"
                )
                .foregroundStyle(.secondary)
            }

            Text(
                account.name
                ?? "Cuenta"
            )
            .font(.subheadline.weight(.medium))
            .lineLimit(1)

            VStack(
                alignment: .leading,
                spacing: 3
            ) {

                Text("SALDO DISPONIBLE")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Text(
                    account.balance,
                    format: .currency(
                        code: "EUR"
                    )
                )
                .font(
                    .headline.weight(.bold)
                )
            }
        }
        .padding(16)
        .frame(
            width: 180,
            alignment: .leading
        )
        .background(
            RoundedRectangle(
                cornerRadius: 18
            )
            .fill(
                Color(.secondarySystemBackground)
            )
        )
    }
}

    private struct RecentTransactionsSection: View {
        
        let transactions: [Transaction]
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                
                HStack {
                    Text("Movimientos Recientes")
                        .font(.headline)
                    
                    Spacer()
                    
//                    Button("Ver historial") {
//                    }
//                    .font(.caption)
                      }
                    
                    VStack(spacing: 0) {
                        
                        if transactions.isEmpty {
                            
                            Text("No hay movimientos todavía")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                            
                        } else {
                            
                            ForEach(transactions) { transaction in
                                TransactionPreview(
                                    transaction: transaction
                                )
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
            }
        }
        
        private struct TransactionPreview: View {
            
            @ObservedObject var transaction: Transaction
            
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
                    
                    // Category icon
                    Image(
                        systemName:
                            transaction.category?.icon
                        ?? "arrow.left.arrow.right"
                    )
                    .font(.subheadline)
                    .frame(width: 38, height: 38)
                    .background(
                        Circle()
                            .fill(
                                isIncome
                                ? Color.green.opacity(0.15)
                                : Color(.systemBackground)
                            )
                    )
                    
                    // Information
                    VStack(
                        alignment: .leading,
                        spacing: 3
                    ) {
                        
                        Text(
                            transaction.note?.isEmpty == false
                            ? transaction.note!
                            : "Transacción"
                        )
                        .font(.subheadline.weight(.medium))
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
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Amount
                    Text(
                        displayAmount,
                        format: .currency(code: "EUR")
                    )
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(
                        isIncome ? .green : .primary
                    )
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
        }
        
    
