import Combine
import CoreData
import Foundation

enum DashboardPeriod {
    case week
    case month
    case year
    case total
}

@MainActor
final class DashboardViewModel: ObservableObject {
    
    @Published var recentTransactions: [Transaction] = []
    
    @Published var totalIncome: Double = 0
    @Published var totalExpenses: Double = 0
    
    @Published var accounts: [Account] = []
    
    private var selectedPeriod: DashboardPeriod = .month
    
    private let repository: TransactionRepository
    
    init(context: NSManagedObjectContext) {
        self.repository = TransactionRepository(
            context: context
        )
    }
    
    func loadDashboard(period: DashboardPeriod? = nil) {
        if let period {
            selectedPeriod = period
        }
        do {
            let transactions = try repository.fetchTransactions()
            
            print("Dashboard transactions:")
            for transaction in transactions.prefix(5) {
                print(
                    transaction.note ?? "Sin nota",
                    transaction.amount
                )
            }
            
            recentTransactions = Array(
                transactions.prefix(5)
            )
            
            calculateTotals(from: transactions)
            
            accounts = try repository.fetchAccounts()
        } catch {
            print("Error loading dashboard: \(error)")
        }
    }
    
    private func calculateTotals(from transactions: [Transaction]) {
        let calendar = Calendar.current
        let today = Date()
        
        let filteredTransactions = transactions.filter { transaction in
            guard let date = transaction.date else {
                return false
            }
            
            switch selectedPeriod {
            case .week:
                return calendar.isDate(
                    date,
                    equalTo: today,
                    toGranularity: .weekOfYear
                )
                
            case .month:
                return calendar.isDate(
                    date,
                    equalTo: today,
                    toGranularity: .month
                )
                
            case .year:
                return calendar.isDate(
                    date,
                    equalTo: today,
                    toGranularity: .year
                )
                
            case .total:
                return true
            }
        }
        
        totalIncome = filteredTransactions
            .filter { $0.type == "income" }
            .reduce(0) { $0 + $1.amount }
        
        totalExpenses = filteredTransactions
            .filter { $0.type == "expense" }
            .reduce(0) { $0 + $1.amount }
        }
    
        var netWorth: Double {
            accounts.reduce(0) { $0 + $1.balance }
        }

        var savings: Double {
            totalIncome - totalExpenses
        }
}
