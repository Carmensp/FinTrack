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
                    
                    CashFlowCard(
                        income: viewModel.totalIncome,
                        expenses: viewModel.totalExpenses,
                        savings: viewModel.savings,
                        //points: []
                    )

                    // Charts will go here
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Flujo de caja")
                            .font(.headline)

                        Chart(viewModel.chartPoints) { point in
                            LineMark(
                                x: .value("Periodo", point.label),
                                y: .value("Ingresos", point.income)
                            )
                            .foregroundStyle(.green)
                            .interpolationMethod(.catmullRom)

                            LineMark(
                                x: .value("Periodo", point.label),
                                y: .value("Gastos", point.expenses)
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
                        Text("Gastos por categoría")
                            .font(.headline)

                        if viewModel.categoryPoints.isEmpty {
                            Text("No hay gastos registrados en este periodo")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 30)
                        } else {
                            Chart(viewModel.categoryPoints) { point in
                                BarMark(
                                    x: .value("Categoría", point.category),
                                    y: .value("Gastos", point.amount)
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
                        Text("Evolución del ahorro")
                            .font(.headline)

                        if viewModel.savingsPoints.isEmpty {
                            Text("No hay movimientos registrados en este periodo")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 30)
                        } else {
                            Chart(viewModel.savingsPoints) { point in
                                LineMark(
                                    x: .value("Periodo", point.label),
                                    y: .value("Ahorro", point.savings)
                                )
                                .foregroundStyle(.green)
                                .interpolationMethod(.catmullRom)

                                AreaMark(
                                    x: .value("Periodo", point.label),
                                    y: .value("Ahorro", point.savings)
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
