import SwiftUI
import CoreData

struct AccountPicker: View {
    let accounts: FetchedResults<Account>

    @Binding var selection: Account?

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(accounts) { account in
                    Button {
                        selection = account
                        dismiss()
                    } label: {
                        Label(
                            account.name ?? "Account",
                            systemImage: account.icon ?? "building.columns"
                        )
                        .foregroundStyle(.primary)
                    }
                }
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
