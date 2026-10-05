import SwiftUI
import CoreData

struct ContentView: View {

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \Transaction.date,
                ascending: false
            )
        ]
    )
    private var transactions:
        FetchedResults<Transaction>

    var body: some View {

        List(transactions) { transaction in

            VStack(alignment: .leading) {

                Text(transaction.note ?? "No note")

                Text(
                    "\(transaction.amount, specifier: "%.2f") €"
                )
                .foregroundStyle(.secondary)
            }
        }
    }
}
