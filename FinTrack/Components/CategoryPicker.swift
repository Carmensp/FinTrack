import SwiftUI
import CoreData

struct CategoryPicker: View {
    let categories: FetchedResults<Category>

    @Binding var selection: Category?

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(categories) { category in
                    Button {
                        selection = category
                        dismiss()
                    } label: {
                        Label(
                            category.name ?? "Category",
                            systemImage: category.icon ?? "folder"
                        )
                        .foregroundStyle(.primary)
                    }
                }
            }
            .navigationTitle("Category")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
