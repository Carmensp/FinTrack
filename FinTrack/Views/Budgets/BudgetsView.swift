import SwiftUI
import CoreData

struct BudgetsView: View {

    @Environment(\.managedObjectContext)
    private var context

    @StateObject private var viewModel: BudgetsViewModel
    
    @State private var showingAddBudget = false
    @State private var budgetToEdit: Budget?

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(
            wrappedValue: BudgetsViewModel(
                context: context
            )
        )
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.budgets.isEmpty {
                    ContentUnavailableView(
                        "No hay presupuestos",
                        systemImage: "chart.bar",
                        description: Text(
                            "Crea tu primer presupuesto para empezar a controlar tus gastos."
                        )
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(viewModel.budgets) { budget in
                                BudgetCard(
                                    budget: budget,
                                    spent: viewModel.spent(for: budget)
                                )
                                .contextMenu {
                                    Button {
                                        budgetToEdit = budget
                                    } label: {
                                        Label(
                                            "Editar",
                                            systemImage: "pencil"
                                        )
                                    }
                                    
                                    Button(role: .destructive) {
                                        viewModel.deleteBudget(budget)
                                    } label: {
                                        Label(
                                            "Eliminar",
                                            systemImage: "trash"
                                        )
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .id(viewModel.refreshID)
                }
            }
            .navigationTitle("Presupuestos")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddBudget = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                viewModel.fetchBudgets()
            }
            .sheet(isPresented: $showingAddBudget) {
                AddBudgetView(context: context)
                    .onDisappear {
                        viewModel.fetchBudgets()
                    }
            }
            .sheet(item: $budgetToEdit) { budget in
                EditBudgetView(
                    context: context,
                    budget: budget
                ) {
                    viewModel.fetchBudgets()
                }
            }
        }
    }
    
}

private struct BudgetCard: View {

    let budget: Budget
    let spent: Double

    private var progress: Double {
        min(
            spent / max(budget.amount, 1),
            1
        )
    }
    
    private var categoryColor: Color {
        switch budget.category?.name {
        case "Alimentación":
            return .orange

        case "Transporte":
            return .blue

        case "Ocio":
            return .purple

        case "Compras":
            return .pink

        case "Suscripciones":
            return .cyan

        case "Vivienda":
            return .brown

        case "Salud":
            return .red

        default:
            return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // MARK: - Header

            HStack {
                HStack(spacing: 10) {

                    Image(
                        systemName:
                            budget.category?.icon
                            ?? "chart.bar"
                    )
                    .foregroundStyle(categoryColor)
                    .frame(
                        width: 38,
                        height: 38
                    )
                    .background(
                        Circle()
                            .fill(
                                categoryColor.opacity(0.15)
                            )
                    )

                    VStack(
                        alignment: .leading,
                        spacing: 3
                    ) {
                        Text(
                            budget.category?.name
                            ?? "Sin categoría"
                        )
                        .font(
                            .subheadline.weight(
                                .semibold
                            )
                        )

                        Text("Este mes")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Text(
                    budget.amount,
                    format: .currency(
                        code: "EUR"
                    )
                )
                .font(
                    .subheadline.weight(
                        .semibold
                    )
                )
            }

            // MARK: - Progress

            VStack(
                alignment: .leading,
                spacing: 6
            ) {

                HStack {

                    Text(
                        "\(spent.formatted(.currency(code: "EUR"))) / \(budget.amount.formatted(.currency(code: "EUR")))"
                    )

                    Spacer()

                    Text(
                        "\(Int(progress * 100))%"
                    )
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                ProgressView(value: progress)
                    .tint(categoryColor)
            }
        }
        .padding(16)
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
