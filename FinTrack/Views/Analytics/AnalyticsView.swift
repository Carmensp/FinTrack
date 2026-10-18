import SwiftUI
import CoreData
import Charts

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
                        Text("Analysis")
                            .font(.title2.weight(.bold))

                        Text("Understand how your money moves.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // Period selector
                    Picker(
                        "Period",
                        selection: $selectedPeriod
                    ) {
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
                    
                    CashFlowCard(
                        income: viewModel.totalIncome,
                        expenses: viewModel.totalExpenses,
                        savings: viewModel.savings,
                    )

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Cash Flow")
                            .font(.headline)

                        Chart(viewModel.chartPoints) { point in
                            LineMark(
                                x: .value("Period", point.label),
                                y: .value("Income", point.income)
                            )
                            .foregroundStyle(.green)
                            .interpolationMethod(.catmullRom)

                            LineMark(
                                x: .value("Period", point.label),
                                y: .value("Expense", point.expenses)
                            )
                            .foregroundStyle(.red)
                            .interpolationMethod(.catmullRom)
                        }
                        .frame(height: 220)
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                        .chartLegend(position: .bottom)
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.secondarySystemBackground))
                    )
                    
                    //Chart de categorias
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Expenses for category")
                            .font(.headline)

                        if viewModel.categoryPoints.isEmpty {
                            Text("There are no expenses recorded for this period")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 30)
                        } else {
                            Chart(viewModel.categoryPoints) { point in
                                BarMark(
                                    x: .value("Category", point.category),
                                    y: .value("Expenses", point.amount)
                                )
                                .foregroundStyle(.red)
                                .cornerRadius(6)
                            }
                            .frame(height: 220)
                            .chartYAxis {
                                AxisMarks(position: .leading)
                            }
                        }
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.secondarySystemBackground))
                    )
                    
                    //Ahorro acumulado
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Evolution of savings")
                            .font(.headline)

                        if viewModel.savingsPoints.isEmpty {
                            Text("There are no transactions recorded for this period")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 30)
                        } else {
                            Chart(viewModel.savingsPoints) { point in
                                LineMark(
                                    x: .value("Period", point.label),
                                    y: .value("Savings", point.savings)
                                )
                                .foregroundStyle(.green)
                                .interpolationMethod(.catmullRom)

                                AreaMark(
                                    x: .value("Period", point.label),
                                    y: .value("Savings", point.savings)
                                )
                                .foregroundStyle(.green.opacity(0.12))
                            }
                            .frame(height: 220)
                            .chartYAxis {
                                AxisMarks(position: .leading)
                            }
                        }
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.secondarySystemBackground))
                    )

                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .navigationTitle("Analysis")
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

private struct AnalyticsMetric: View {
    let title: String
    let amount: Double
    let color: Color

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 4
        ) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(
                amount,
                format: .currency(code: "EUR")
            )
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(color)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }
}
