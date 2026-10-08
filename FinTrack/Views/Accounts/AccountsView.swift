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
            wrappedValue: AccountsViewModel(
                context: context
            )
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // MARK: - Header

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tus cuentas")
                            .font(
                                .title2.weight(.bold)
                            )

                        Text(
                            "Gestiona tus cuentas y saldos"
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }

                    // MARK: - Total Balance

                    TotalBalanceCard(
                        accounts: viewModel.accounts
                    )

                    // MARK: - Accounts

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Mis cuentas")
                                .font(.headline)

                            Spacer()

                            Button {
                                showingAddAccount = true
                            } label: {
                                Image(
                                    systemName: "plus"
                                )
                                .font(
                                    .subheadline.weight(
                                        .semibold
                                    )
                                )
                            }
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
                                    AccountCard(
                                        account: account
                                    )
                                    .contextMenu {
                                        Button {
                                            accountToEdit =
                                                account
                                        } label: {
                                            Label(
                                                "Editar",
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
                                                "Eliminar",
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
            .navigationTitle("Cuentas")
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
            .sheet(
                item: $accountToEdit
            ) { account in
                EditAccountView(
                    context: context,
                    account: account
                ) {
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
            Text("SALDO TOTAL")
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
                    ? "cuenta"
                    : "cuentas")
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

// MARK: - Account Card

private struct AccountCard: View {
    @ObservedObject var account: Account

    private var accountColor: Color {
        switch account.icon {
        case "building.columns":
            return .blue
        case "banknote":
            return .green
        case "creditcard":
            return .purple
        default:
            return .orange
        }
    }

    var body: some View {
        HStack(spacing: 14) {

            Image(
                systemName:
                    account.icon
                    ?? "building.columns"
            )
            .foregroundStyle(accountColor)
            .frame(
                width: 46,
                height: 46
            )
            .background(
                Circle()
                    .fill(
                        accountColor.opacity(0.12)
                    )
            )

            VStack(
                alignment: .leading,
                spacing: 4
            ) {
                Text(
                    account.name
                    ?? "Sin nombre"
                )
                .font(
                    .subheadline.weight(.semibold)
                )

                Text("SALDO DISPONIBLE")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(
                account.balance,
                format: .currency(code: "EUR")
            )
            .font(
                .subheadline.weight(.semibold)
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    Color(.secondarySystemBackground)
                )
        )
    }
}

// MARK: - Empty State

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

            Text("No tienes cuentas")
                .font(.headline)

            Text(
                "Añade tu primera cuenta para empezar."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)

            Button("Añadir cuenta") {
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
