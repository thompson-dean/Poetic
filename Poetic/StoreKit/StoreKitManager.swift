//
//  StoreKitManager.swift
//  Poetic
//
//  Created by Dean Thompson on 2023/07/20.
//

import Foundation
import StoreKit

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

    private var transactionListener: TransactionListener?

    init() {
        transactionListener = confiureTransactionListener()
        Task { [weak self] in
            await self?.retrieveProducts()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    func purchase(_ item: Product) async {
        do {
            let result = try await item.purchase()

            try await handlePurchase(from: result)
        } catch {
            paymentState = .failed(.system(error))
            print("DEBUG: \(error.localizedDescription)")
        }
    }

    func reset() {
        paymentState = nil
    }
}

private extension StoreKitManager {
    func confiureTransactionListener() -> TransactionListener {
        Task.detached(priority: .background) { @MainActor [weak self] in
            do {
                for await result in Transaction.updates {
                    let transaction = try self?.checkVerified(result)
                    self?.paymentState = .successful
                    await transaction?.finish()
                }
            } catch {
                self?.paymentState = .failed(.system(error))
                print(error)
            }
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

    func handlePurchase(from result: PurchaseResult) async throws {
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            paymentState = .successful
            await transaction.finish()
        case .pending:
            paymentState = .pending
        case .userCancelled:
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
