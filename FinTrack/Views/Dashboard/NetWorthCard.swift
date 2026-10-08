
import SwiftUI

struct NetWorthCard: View {

    let netWorth: Double
    let income: Double
    let expenses: Double
    let savings: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Header
            HStack {
                Label("PATRIMONIO NETO", systemImage: "creditcard")

                Spacer()

                Image(systemName: "eye")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            // Net worth
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(netWorth, format: .currency(code: "EUR"))
                    .font(.system(size: 30, weight: .bold))

                Text("EUR")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 6) {
                Image(systemName: savings >= 0 ? "arrow.up.right" : "arrow.down.right")

                Text(
                    "\(savings >= 0 ? "+" : "")\(savings, format: .currency(code: "EUR")) este mes"
                )
            }
            .font(.caption)
            .foregroundStyle(
                savings >= 0 ? .green : .red.opacity(0.9)
            )

//            // Comparison
//            Text("↗ +€1.240,00 (+8,4% vs anterior)")
//                .font(.caption)
//                .foregroundStyle(.green)

            // Income / Expenses
            HStack(spacing: 12) {

                SummaryItem(
                    title: "Ingresos",
                    amount: income,
                    icon: "arrow.down"
                )
                .frame(maxWidth: .infinity)
                .frame(height: 50)

                SummaryItem(
                    title: "Gastos",
                    amount: expenses,
                    icon: "arrow.up"
                )
                .frame(maxWidth: .infinity)
                .frame(height: 50)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

private struct SummaryItem: View {

    let title: String
    let amount: Double
    let icon: String

    var body: some View {
        HStack(spacing: 10) {

            Image(systemName: icon)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.green.opacity(0.15))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(amount, format: .currency(code: "EUR"))
                    .font(.subheadline.weight(.semibold))
            }

            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground).opacity(0.5))
        )
    }
}
