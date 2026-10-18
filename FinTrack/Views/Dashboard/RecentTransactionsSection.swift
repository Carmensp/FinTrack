import SwiftUI
import CoreData

struct RecentTransactionsSection: View {
    
    let transactions: [Transaction]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                Text("Recent movements")
                    .font(.headline)
                
                Spacer()
                }
                
                VStack(spacing: 0) {
                    
                    if transactions.isEmpty {
                        
                        Text("There is no transactions yet")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                        
                    } else {
                        
                        ForEach(transactions) { transaction in
                            TransactionPreview(
                                transaction: transaction
                            )
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )
            }
        }
    }

struct TransactionPreview: View {
    
    @ObservedObject var transaction: Transaction
    
    private var isIncome: Bool {
        transaction.type == "income"
    }
    
    private var displayAmount: Double {
        isIncome
        ? transaction.amount
        : -transaction.amount
    }
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            Image(
                systemName:
                    transaction.category?.icon
                ?? "arrow.left.arrow.right"
            )
            .font(.subheadline)
            .frame(width: 38, height: 38)
            .background(
                Circle()
                    .fill(
                        isIncome
                        ? Color.green.opacity(0.15)
                        : Color(.systemBackground)
                    )
            )
            
            VStack(
                alignment: .leading,
                spacing: 3
            ) {
                
                Text(
                    transaction.note?.isEmpty == false
                    ? transaction.note!
                    : "Transaction"
                )
                .font(.subheadline.weight(.medium))
                .lineLimit(1)
                
                HStack(spacing: 4) {
                    
                    Text(
                        transaction.category?.name
                        ?? "Uncategorized"
                    )
                    
                    Text("•")
                    
                    Text(
                        transaction.account?.name
                        ?? "Without an account"
                    )
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            }
            
            Spacer()

            Text(
                displayAmount,
                format: .currency(code: "EUR")
            )
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(
                isIncome ? .green : .primary
            )
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

