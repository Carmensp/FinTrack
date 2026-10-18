import SwiftUI

struct AccountsSection: View {

    let accounts: [Account]

    var body: some View {

        VStack(alignment: .leading, spacing: 12) {

            HStack {

                Text("Your Accounts")
                    .font(.headline)

                Spacer()
            }

            ScrollView(
                .horizontal,
                showsIndicators: false
            ) {

                HStack(spacing: 12) {

                    ForEach(accounts) { account in

                        AccountCard(
                            account: account
                        )
                    }
                }
            }
        }
    }
}

struct AccountCard: View {

    let account: Account

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            HStack {

                Image(
                    systemName:
                        account.icon
                        ?? "building.columns"
                )
                .font(.subheadline)
                .frame(
                    width: 34,
                    height: 34
                )
                .background(
                    Circle()
                        .fill(
                            Color(.systemBackground)
                        )
                )

                Spacer()
            }

            Text(
                account.name
                ?? "Account"
            )
            .font(.subheadline.weight(.medium))
            .lineLimit(1)

            VStack(
                alignment: .leading,
                spacing: 3
            ) {

                Text("AVAILABLE BALANCE")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Text(
                    account.balance,
                    format: .currency(
                        code: "EUR"
                    )
                )
                .font(
                    .headline.weight(.bold)
                )
            }
        }
        .padding(16)
        .frame(
            width: 180,
            alignment: .leading
        )
        .background(
            RoundedRectangle(
                cornerRadius: 18
            )
            .fill(
                Color(.secondarySystemBackground)
            )
        )
    }
}
