import SwiftUI
import Charts

struct DashboardChartCard: View {
    let income: Double
    let expenses: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cash Flow")
                        .font(.headline)

                    Text("Incomes and expenses")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(.green)
            }

            Chart {
                BarMark(
                    x: .value("Type", "Incomes"),
                    y: .value("Amount", income)
                )
                .foregroundStyle(.green)

                BarMark(
                    x: .value("Type", "Expenses"),
                    y: .value("Amount", expenses)
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
