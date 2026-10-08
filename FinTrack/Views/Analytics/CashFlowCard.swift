import SwiftUI

struct CashFlowCard: View {
    let income: Double
    let expenses: Double
    let savings: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Flujo de caja")
                    .font(.headline)

                Spacer()

                Text("Este mes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                CashFlowItem(
                    title: "Ingresos",
                    amount: income,
                    icon: "arrow.down.left",
                    color: .green
                )

                CashFlowItem(
                    title: "Gastos",
                    amount: expenses,
                    icon: "arrow.up.right",
                    color: .red
                )
            }

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ahorro")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(
                        savings,
                        format: .currency(code: "EUR")
                    )
                    .font(.title3.weight(.bold))
                    .foregroundStyle(
                        savings >= 0 ? .green : .red
                    )
                }

                Spacer()

                Image(
                    systemName: savings >= 0
                        ? "chart.line.uptrend.xyaxis"
                        : "chart.line.downtrend.xyaxis"
                )
                .font(.title2)
                .foregroundStyle(
                    savings >= 0 ? .green : .red
                )
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

private struct CashFlowItem: View {
    let title: String
    let amount: Double
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .frame(width: 34, height: 34)
                .foregroundStyle(color)
                .background(
                    Circle()
                        .fill(color.opacity(0.12))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(
                    amount,
                    format: .currency(code: "EUR")
                )
                .font(.subheadline.weight(.semibold))
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

