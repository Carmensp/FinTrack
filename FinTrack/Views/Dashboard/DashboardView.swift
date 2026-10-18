
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

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hi, financial expert ✨")
                            .font(.title2.weight(.bold))
                    }

                    Picker("Period", selection: $selectedPeriod) {
                        Text("This month")
                            .tag(DashboardPeriod.month)

                        Text("Week")
                            .tag(DashboardPeriod.week)

                        Text("Year")
                            .tag(DashboardPeriod.year)

                        Text("Total")
                            .tag(DashboardPeriod.total)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedPeriod) { _, newValue in
                        viewModel.loadDashboard(period: newValue)
                    }
                    
                    NetWorthCard(
                        netWorth: viewModel.netWorth,
                        income: viewModel.totalIncome,
                        expenses: viewModel.totalExpenses,
                        savings: viewModel.savings,
                        period: selectedPeriod
                    )

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
                                Text("View analysis")
                                    .font(.headline)

                                Text("View detailed charts of your finances")
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

                    AccountsSection(
                        accounts: viewModel.accounts
                    )
                    .id(
                        viewModel.accounts.map {
                            "\($0.objectID.uriRepresentation().absoluteString)-\($0.name ?? "")-\($0.balance)-\($0.icon ?? "")"
                        }
                        .joined(separator: "|")
                    )

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
                viewModel.loadDashboard(period: selectedPeriod)
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
