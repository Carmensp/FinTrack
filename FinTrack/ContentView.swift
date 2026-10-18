import SwiftUI
import CoreData

struct ContentView: View {

    @Environment(\.managedObjectContext)
    private var context

    var body: some View {

        TabView {

            DashboardView(
                context: context
            )
            .tabItem {
                Label(
                    "Summary",
                    systemImage: "house"
                )
            }

            TransactionsView(
                context: context
            )
            .tabItem {
                Label(
                    "Transactions",
                    systemImage: "arrow.left.arrow.right"
                )
            }

             BudgetsView(
                 context: context
             )
             .tabItem {
                 Label(
                     "Budgets",
                     systemImage: "chart.bar"
                 )
            }

            AccountsView(context: context)
                .tabItem {
                    Label(
                        "Accounts",
                        systemImage: "creditcard"
                    )
                }
        }
    }
}
