//
//  StoreKitManager.swift
//  Poetic
//
//  Created by Dean Thompson on 2023/07/20.
//

import Foundation
import StoreKit
import WidgetKit

enum PaymentError: LocalizedError {
    case failedVerification
    case system(Error)

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "User transaction verification failed"
        case .system(let error):
            return error.localizedDescription
        }
    }
}

enum PaymentState: Equatable {
    case successful
    case pending
    case failed(PaymentError)

    static func == (lhs: PaymentState, rhs: PaymentState) -> Bool {
        switch(lhs, rhs) {
        case (.successful, .successful):
            return true
        case (.pending, .pending):
            return true
        case (let .failed(lhsError), let .failed(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

typealias PurchaseResult = Product.PurchaseResult
typealias TransactionListener = Task<Void, Error>

@MainActor
final class StoreKitManager: ObservableObject {
    @Published private(set) var items: [Product] = []
    @Published private(set) var isSupporter: Bool
    @Published var hasError: Bool = false
    @Published private(set) var paymentState: PaymentState? {
        didSet {
            switch paymentState {
            case .failed:
                hasError = true
            default:
                hasError = false
            }
        }
    }

    var error: PaymentError? {
        switch paymentState {
        case .failed(let error):
            return error
        default:
            return nil
        }
    }

    var tips: [Product] {
        items.filter { $0.type == .consumable }
    }

    private let entitlement: SupporterEntitlement
    private var transactionListener: TransactionListener?

    init(entitlement: SupporterEntitlement = SupporterEntitlement()) {
        self.entitlement = entitlement
        // Cached flag keeps the UI correct offline and before the
        // entitlement refresh completes.
        self.isSupporter = entitlement.isSupporter
        transactionListener = configureTransactionListener()
        Task { [weak self] in
            await self?.retrieveProducts()
            await self?.refreshEntitlements()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    func purchase(_ item: Product) async {
        do {
            let result = try await item.purchase()

            try await handlePurchase(from: result, of: item)
        } catch {
            paymentState = .failed(.system(error))
            AnalyticsEvents.purchaseFailed(productID: item.id, reason: error.localizedDescription)
            print("DEBUG: \(error.localizedDescription)")
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            AnalyticsEvents.restoreCompleted(unlocked: isSupporter)
        } catch {
            paymentState = .failed(.system(error))
        }
    }

    /// Any past tip unlocks supporter status. Finished consumables never
    /// appear in currentEntitlements; they show up in Transaction.all only
    /// on iOS 18+ with SKIncludeConsumableInAppPurchaseHistory set in the
    /// Info.plist. Grant-only: an empty history (iOS 17, or Apple trimming
    /// it) must never revoke a locally stored unlock.
    func refreshEntitlements() async {
        for await result in Transaction.all {
            guard case .verified(let transaction) = result else { continue }
            if Constants.tipIdentifiers.contains(transaction.productID),
               transaction.revocationDate == nil {
                setSupporter(true)
                return
            }
        }
    }

    func reset() {
        paymentState = nil
    }
}

private extension StoreKitManager {
    func configureTransactionListener() -> TransactionListener {
        Task.detached(priority: .background) { @MainActor [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                // Per-iteration catch: one failed verification must not
                // kill the listener for the rest of the session.
                do {
                    let transaction = try self.checkVerified(result)
                    self.handle(transaction)
                    await transaction.finish()
                } catch {
                    print("DEBUG: transaction update failed verification: \(error)")
                }
            }
        }
    }

    func handle(_ transaction: Transaction) {
        guard transaction.revocationDate == nil else { return }
        // Every tip unlocks supporter status, and a refund doesn't take it
        // back — the flag is deliberately sticky.
        if Constants.tipIdentifiers.contains(transaction.productID) {
            setSupporter(true)
        }
        paymentState = .successful
    }

    func setSupporter(_ value: Bool) {
        entitlement.set(value)
        guard value != isSupporter else { return }
        isSupporter = value
        WidgetCenter.shared.reloadAllTimelines()
        if value {
            AnalyticsEvents.widgetUnlocked()
        }
    }

    func retrieveProducts() async {
        do {
            let products = try await Product.products(
                for: Constants.storeKitIdentifiers
            ).sorted(by: { $0.price < $1.price})
            items = products
        } catch {
            paymentState = .failed(.system(error))
            print("DEBUG: \(error.localizedDescription)")
        }
    }

    func handlePurchase(from result: PurchaseResult, of item: Product) async throws {
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            handle(transaction)
            await transaction.finish()
            AnalyticsEvents.purchaseSuccess(productID: item.id)
        case .pending:
            paymentState = .pending
        case .userCancelled:
            AnalyticsEvents.purchaseCancelled(productID: item.id)
            print("cancelled")
        @unknown default:
            break
        }
    }

    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            print("The verfication of the user failed.")
            throw PaymentError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}
