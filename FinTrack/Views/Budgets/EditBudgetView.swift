import SwiftUI
import CoreData

struct EditBudgetView: View {

    @Environment(\.dismiss)
    private var dismiss

    @FetchRequest(
        entity: Category.entity(),
        sortDescriptors: [
            NSSortDescriptor(
                key: "name",
                ascending: true
            )
        ]
    )
    private var categories: FetchedResults<Category>

    @StateObject private var viewModel: BudgetsViewModel

    let budget: Budget

    @State private var amountText: String
    @State private var month: Date
    @State private var selectedCategory: Category?

    let onSave: () -> Void

    init(
        context: NSManagedObjectContext,
        budget: Budget,
        onSave: @escaping () -> Void
    ) {
        self.budget = budget
        self.onSave = onSave

        _viewModel = StateObject(
            wrappedValue: BudgetsViewModel(
                context: context
            )
        )

        _amountText = State(
            initialValue: String(
                format: "%.2f",
                budget.amount
            )
        )

        _month = State(
            initialValue: budget.month ?? Date()
        )

        _selectedCategory = State(
            initialValue: budget.category
        )
    }

    var body: some View {
        NavigationStack {
            Form {

                Section("Presupuesto") {

                    TextField(
                        "Cantidad",
                        text: $amountText
                    )
                    .keyboardType(.decimalPad)

                    Picker(
                        "Categoría",
                        selection: $selectedCategory
                    ) {
                        Text("Seleccionar")
                            .tag(nil as Category?)

                        ForEach(categories) { category in
                            Text(
                                category.name
                                ?? "Sin nombre"
                            )
                            .tag(category as Category?)
                        }
                    }

                    DatePicker(
                        "Mes",
                        selection: $month,
                        displayedComponents: .date
                    )
                }

                Section {
                    Button("Guardar cambios") {
                        saveChanges()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Editar presupuesto")
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

    private func saveChanges() {

        let normalizedAmount =
            amountText.replacingOccurrences(
                of: ",",
                with: "."
            )

        guard let amount = Double(normalizedAmount),
              amount > 0
        else {
            return
        }

        guard let selectedCategory else {
            return
        }

        viewModel.updateBudget(
            budget,
            amount: amount,
            month: month,
            category: selectedCategory
        )

        onSave()
        dismiss()
    }
}
