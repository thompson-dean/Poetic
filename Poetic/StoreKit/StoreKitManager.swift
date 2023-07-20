//
//  StoreKitManager.swift
//  Poetic
//
//  Created by Dean Thompson on 2023/07/20.
//

import Foundation
import StoreKit

enum PaymentError: Error {
    case failedVerification
}

enum PaymentState {
    case successful
}

typealias PurchaseResult = Product.PurchaseResult

final class StoreKitManager: ObservableObject {
    @Published private(set) var items: [Product] = []
    @Published private(set) var paymentState: PaymentState?
    
    init() {
        Task { [weak self] in
            await self?.retrieveProducts()
        }
    }
    
    func purchase(_ item: Product) async {
        do {
            let result = try await item.purchase()
            
            try await handlePurchase(from: result)
        } catch {
            print("DEBUG: \(error.localizedDescription)")
        }
    }
    
    func reset() {
        paymentState = nil
    }
}

private extension StoreKitManager {
    @MainActor
    func retrieveProducts() async {
        do {
            let products = try await Product.products(for: Constants.storeKitIdentifiers).sorted(by: { $0.price < $1.price})
            items = products
        } catch {
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
            print("pending")
        case .userCancelled:
            print("canclled")
        @unknown default:
            break
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, _):
            print("The verfication of the user failed.")
            throw PaymentError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}
