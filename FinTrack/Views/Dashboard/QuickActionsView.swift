import SwiftUI
import CoreData

struct QuickActionsView: View {
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
                    title: "Income/Expense"
                )
            }

            NavigationLink {
                TransactionsView(context: context)
            } label: {
                QuickAction(
                    icon: "arrow.left.arrow.right",
                    title: "Transactions"
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                BudgetsView(context: context)
            } label: {
                QuickAction(
                    icon: "chart.bar",
                    title: "Budgets"
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                AccountsView(context: context)
            } label: {
                QuickAction(
                    icon: "creditcard",
                    title: "Accounts"
                )
            }
            .buttonStyle(.plain)
        }
    }
}

struct QuickAction: View {
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

