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
                    "Resumen",
                    systemImage: "house"
                )
            }

            TransactionsView(
                context: context
            )
            .tabItem {
                Label(
                    "Transacciones",
                    systemImage: "arrow.left.arrow.right"
                )
            }

             BudgetsView(
                 context: context
             )
             .tabItem {
                 Label(
                     "Presupuestos",
                     systemImage: "chart.bar"
                 )
            }

            AccountsView(context: context)
                .tabItem {
                    Label(
                        "Cuentas",
                        systemImage: "creditcard"
                    )
                }
        }
    }
}
