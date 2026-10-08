import SwiftUI
import CoreData

struct EditAccountView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: AccountsViewModel

    let account: Account
    let onSave: () -> Void

    @State private var name: String
    @State private var selectedIcon: String
    @State private var balance: String

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
        account: Account,
        onSave: @escaping () -> Void
    ) {
        self.account = account
        self.onSave = onSave

        _viewModel = StateObject(
            wrappedValue: AccountsViewModel(
                context: context
            )
        )

        _name = State(
            initialValue: account.name ?? ""
        )

        _selectedIcon = State(
            initialValue:
                account.icon ?? "building.columns"
        )
        _balance = State(
            initialValue: String(format: "%.2f", account.balance)
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
                                ? "Cuenta"
                                : name
                        )
                        .font(
                            .title3.weight(.semibold)
                        )

                        Text("SALDO DISPONIBLE")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        Text(
                            account.balance,
                            format: .currency(
                                code: "EUR"
                            )
                        )
                        .font(
                            .title2.weight(.bold)
                        )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)

                    // MARK: - Name

                    VStack(
                        alignment: .leading,
                        spacing: 10
                    ) {
                        Text("NOMBRE")
                            .font(
                                .caption.weight(.semibold)
                            )
                            .foregroundStyle(.secondary)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("SALDO ACTUAL")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)

                            TextField("0,00 €", text: $balance)
                                .keyboardType(.decimalPad)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.secondarySystemBackground))
                                )
                        }

                        TextField(
                            "Ej. Cuenta principal",
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
                        Text("ICONO")
                            .font(
                                .caption.weight(.semibold)
                            )
                            .foregroundStyle(.secondary)

                        LazyVGrid(
                            columns: [
                                GridItem(
                                    .adaptive(
                                        minimum: 58
                                    )
                                )
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

                    // MARK: - Balance Info

                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 10) {
                            Image(systemName: "info.circle")
                                .foregroundStyle(.green)

                            Text("Sobre el saldo")
                                .font(.subheadline.weight(.semibold))
                        }

                        Text(
                            "Puedes corregir el saldo actual sin modificar los movimientos registrados."
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.green.opacity(0.08))
                    )
                
                    // MARK: - Save

                    Button {
                        saveChanges()
                    } label: {
                        Text("Guardar cambios")
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
            .navigationTitle("Editar cuenta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .topBarLeading
                ) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Save

    private func saveChanges() {
        let cleanName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanName.isEmpty else {
            return
        }

        let normalizedBalance = balance
            .replacingOccurrences(of: ",", with: ".")

        let newBalance = Double(normalizedBalance) ?? account.balance

        viewModel.updateAccount(
            account,
            name: cleanName,
            balance: newBalance,
            icon: selectedIcon
        )

        onSave()
        dismiss()
    }
}
