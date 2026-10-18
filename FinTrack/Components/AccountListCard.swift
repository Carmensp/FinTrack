
import SwiftUI

struct AccountListCard: View {
    let account: Account

    private let palette: [Color] = [
        .green,
        .blue,
        .purple,
        .orange,
        .pink,
        .cyan,
        .indigo,
        .mint,
        .yellow,
        .red
    ]

    private var accountColor: Color {
        let name = account.name ?? ""
        let hash = name.unicodeScalars.reduce(0) {
            ($0 &* 31 &+ Int($1.value)) & 0x7fffffff
        }

        return palette[hash % palette.count]
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(
                systemName: account.icon ?? "building.columns"
            )
            .font(.title3)
            .foregroundStyle(accountColor)
            .frame(width: 48, height: 48)
            .background(
                Circle()
                    .fill(accountColor.opacity(0.15))
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(account.name ?? "Account")
                    .font(.headline)
                    .lineLimit(1)

                Text("AVAILABLE BALANCE")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Text(
                account.balance,
                format: .currency(code: "EUR")
            )
            .font(.headline.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.75)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
