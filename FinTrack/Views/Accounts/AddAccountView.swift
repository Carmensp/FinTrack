import SwiftUI
import CoreData

struct AddAccountView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: AccountsViewModel

    @State private var name = ""
    @State private var selectedIcon = "building.columns"
    @State private var initialBalance = ""

    let onSave: () -> Void

    private let icons = [
        "building.columns",
        "banknote",
        "creditcard",
        "wallet.pass",
        "house",
        "briefcase",
        "chart.line.uptrend.xyaxis"
    ]

    init(
        context: NSManagedObjectContext,
        onSave: @escaping () -> Void
    ) {
        self.onSave = onSave

        _viewModel = StateObject(
            wrappedValue: AccountsViewModel(
                context: context
            )
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: 24
                ) {

                    // MARK: - Preview

                    VStack(spacing: 12) {
                        Image(
                            systemName: selectedIcon
                        )
                        .font(.system(size: 34))
                        .foregroundStyle(.green)
                        .frame(
                            width: 72,
                            height: 72
                        )
                        .background(
                            Circle()
                                .fill(
                                    Color.green.opacity(0.12)
                                )
                        )

                        Text(
                            name.isEmpty
                                ? "New account"
                                : name
                        )
                        .font(
                            .title3.weight(.semibold)
                        )
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("OPENING BALANCE")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)

                            TextField("0,00 €", text: $initialBalance)
                                .keyboardType(.decimalPad)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.secondarySystemBackground))
                                )
                        }

                        Text("AVAILABLE BALANCE")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)

                    // MARK: - Name

                    VStack(
                        alignment: .leading,
                        spacing: 10
                    ) {
                        Text("NAME")
                            .font(
                                .caption.weight(.semibold)
                            )
                            .foregroundStyle(.secondary)

                        TextField(
                            "Ej. Main Account",
                            text: $name
                        )
                        .padding(16)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 16
                            )
                            .fill(
                                Color(
                                    .secondarySystemBackground
                                )
                            )
                        )
                    }

                    // MARK: - Icon

                    VStack(
                        alignment: .leading,
                        spacing: 10
                    ) {
                        Text("ICON")
                            .font(
                                .caption.weight(.semibold)
                            )
                            .foregroundStyle(.secondary)

                        LazyVGrid(
                            columns: [
                                GridItem(.adaptive(minimum: 58))
                            ],
                            spacing: 12
                        ) {
                            ForEach(
                                icons,
                                id: \.self
                            ) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    Image(
                                        systemName: icon
                                    )
                                    .font(.title3)
                                    .frame(
                                        width: 58,
                                        height: 58
                                    )
                                    .foregroundStyle(
                                        selectedIcon == icon
                                            ? .green
                                            : .secondary
                                    )
                                    .background(
                                        RoundedRectangle(
                                            cornerRadius: 14
                                        )
                                        .fill(
                                            selectedIcon == icon
                                                ? Color.green
                                                    .opacity(0.12)
                                                : Color(
                                                    .secondarySystemBackground
                                                )
                                        )
                                    )
                                    .overlay {
                                        RoundedRectangle(
                                            cornerRadius: 14
                                        )
                                        .stroke(
                                            selectedIcon == icon
                                                ? Color.green
                                                    .opacity(0.35)
                                                : .clear,
                                            lineWidth: 1
                                        )
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // MARK: - Info

                    VStack(
                        alignment: .leading,
                        spacing: 8
                    ) {
                        HStack(spacing: 10) {
                            Image(
                                systemName: "info.circle"
                            )
                            .foregroundStyle(.green)

                            Text("Account balance")
                                .font(
                                    .subheadline.weight(
                                        .semibold
                                    )
                                )
                        }

                        Text(
                            "Your balance will be calculated automatically based on your transactions."
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(
                            cornerRadius: 16
                        )
                        .fill(
                            Color.green.opacity(0.08)
                        )
                    )

                    // MARK: - Save

                    Button {
                        saveAccount()
                    } label: {
                        Text("Create account")
                            .font(
                                .headline.weight(.semibold)
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 16
                        )
                    )
                    .disabled(
                        name.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty
                    )
                    .opacity(
                        name.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty
                            ? 0.5
                            : 1
                    )
                }
                .padding(20)
            }
            .background(
                Color(.systemBackground)
                    .ignoresSafeArea()
            )
            .navigationTitle("New account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .topBarLeading
                ) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Save

    private func saveAccount() {
        let cleanName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanName.isEmpty else {
            return
        }

        let normalizedBalance = initialBalance
            .replacingOccurrences(of: ",", with: ".")

        let balance = Double(normalizedBalance) ?? 0

        viewModel.createAccount(
            name: cleanName,
            initialBalance: balance,
            icon: selectedIcon
        )

        onSave()
        dismiss()
    }
}

