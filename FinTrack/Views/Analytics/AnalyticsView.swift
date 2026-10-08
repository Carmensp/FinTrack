import SwiftUI
import CoreData

struct AnalyticsView: View {
    @Environment(\.managedObjectContext)
    private var context

    @StateObject private var viewModel: AnalyticsViewModel

    @State private var selectedPeriod: DashboardPeriod = .month

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(
            wrappedValue: AnalyticsViewModel(
                context: context
            )
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Análisis")
                            .font(.title2.weight(.bold))

                        Text("Entiende cómo se mueve tu dinero")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // Period selector
                    Picker(
                        "Periodo",
                        selection: $selectedPeriod
                    ) {
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

                    // Summary
                    AnalyticsSummaryCard(
                        income: viewModel.totalIncome,
                        expenses: viewModel.totalExpenses,
                        savings: viewModel.savings
                    )

                    // Charts will go here
                    Text("Gráficos")
                        .font(.headline)

                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .navigationTitle("Análisis")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadAnalytics(
                    period: selectedPeriod
                )
            }
            .onChange(of: selectedPeriod) { _, newValue in
                viewModel.loadAnalytics(
                    period: newValue
                )
            }
        }
    }
}

