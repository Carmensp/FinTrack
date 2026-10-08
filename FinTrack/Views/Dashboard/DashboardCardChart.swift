import SwiftUI
import Charts

struct DashboardChartCard: View {
    let income: Double
    let expenses: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Flujo de dinero")
                        .font(.headline)

                    Text("Ingresos y gastos")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(.green)
            }

            Chart {
                BarMark(
                    x: .value("Tipo", "Ingresos"),
                    y: .value("Cantidad", income)
                )
                .foregroundStyle(.green)

                BarMark(
                    x: .value("Tipo", "Gastos"),
                    y: .value("Cantidad", expenses)
                )
                .foregroundStyle(.red)
            }
            .frame(height: 180)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
