import SwiftUI
import CoreData

struct AccountsView: View {
    @Environment(\.managedObjectContext)
    private var context

    @StateObject private var viewModel: AccountsViewModel

    @State private var showingAddAccount = false
    @State private var accountToEdit: Account?

    init(context: NSManagedObjectContext) {

        _viewModel = StateObject(
            wrappedValue: AccountsViewModel(context: context)
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // MARK: - Header

                    VStack(alignment: .leading, spacing: 4) {
                        Text("My Accounts")
                            .font(
                                .title2.weight(.bold)
                            )

                        Text(
                            "Manage your accounts and balances"
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }

                    // MARK: - Total Balance

                    TotalBalanceCard(
                        accounts: viewModel.accounts
                    )
                    .id(
                        viewModel.accounts.map {
                            "\($0.objectID.uriRepresentation().absoluteString)-\($0.balance)"
                        }
                        .joined(separator: "|")
                    )

                    // MARK: - Accounts

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("My accounts")
                                .font(.headline)

                            Spacer()
                        }

                        if viewModel.accounts.isEmpty {
                            EmptyAccountsView {
                                showingAddAccount = true
                            }
                        } else {
                            VStack(spacing: 10) {
                                ForEach(
                                    viewModel.accounts
                                ) { account in
                                    AccountListCard(
                                        account: account
                                    )
                                    .id(
                                        "\(account.objectID.uriRepresentation().absoluteString)-\(account.name ?? "")-\(account.balance)-\(account.icon ?? "")"
                                    )
                                    .frame(maxWidth: .infinity)
                                    .contextMenu {
                                        Button {
                                            accountToEdit =
                                                account
                                        } label: {
                                            Label(
                                                "Edit",
                                                systemImage:
                                                    "pencil"
                                            )
                                        }

                                        Button(
                                            role: .destructive
                                        ) {
                                            viewModel
                                                .deleteAccount(
                                                    account
                                                )
                                        } label: {
                                            Label(
                                                "Delete",
                                                systemImage:
                                                    "trash"
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(
                Color(.systemBackground)
                    .ignoresSafeArea()
            )
            .navigationTitle("Accounts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .topBarTrailing
                ) {
                    Button {
                        showingAddAccount = true
                    } label: {
                        Image(
                            systemName: "plus"
                        )
                    }
                }
            }
            .onAppear {
                viewModel.fetchAccounts()
            }
            .sheet(
                isPresented: $showingAddAccount
            ) {
                AddAccountView(
                    context: context
                ) {
                    viewModel.fetchAccounts()
                }
            }
            .sheet(item: $accountToEdit) { account in
                EditAccountView(
                    context: context,
                    account: account
                ) {
                    viewModel.fetchAccounts()
                }
                .onDisappear {
                    viewModel.fetchAccounts()
                }
            }
        }
    }
}

// MARK: - Total Balance

private struct TotalBalanceCard: View {
    let accounts: [Account]

    private var totalBalance: Double {
        accounts.reduce(0) {
            $0 + $1.balance
        }
    }

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 8
        ) {
            Text("TOTAL BALANCE")
                .font(
                    .caption.weight(.semibold)
                )
                .foregroundStyle(.white.opacity(0.7))

            Text(
                totalBalance,
                format: .currency(code: "EUR")
            )
            .font(
                .system(
                    size: 32,
                    weight: .bold
                )
            )
            .foregroundStyle(.white)

            Text(
                "\(accounts.count) "
                + (accounts.count == 1
                    ? "account"
                    : "accounts")
            )
            .font(.caption)
            .foregroundStyle(.white.opacity(0.7))
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    Color.green.opacity(0.9),
                    Color.green.opacity(0.55),
                    Color.black.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 22)
        )
    }
}

// MARK: - Empty View

private struct EmptyAccountsView: View {
    let action: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(
                systemName:
                    "building.columns"
            )
            .font(.system(size: 32))
            .foregroundStyle(.secondary)

            Text("You don't have accounts yet")
                .font(.headline)

            Text(
                "Add your first account to get started"
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)

            Button("Add account") {
                action()
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .frame(maxWidth: .infinity)
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    Color(.secondarySystemBackground)
                )
        )
    }
}
