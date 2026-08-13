//
//  SupporterEntitlementTests.swift
//  PoeticTests
//
//  Created by Dean Thompson on 2026/08/11.
//

import XCTest
@testable import Poetic

final class SupporterEntitlementTests: XCTestCase {
    private let suiteName = "SupporterEntitlementTests"
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        super.tearDown()
    }

    func test_defaultsToFalseWhenUnset() {
        XCTAssertFalse(SupporterEntitlement(defaults: defaults).isSupporter)
    }

    func test_setTrue_roundTrips() {
        let entitlement = SupporterEntitlement(defaults: defaults)
        entitlement.set(true)
        XCTAssertTrue(entitlement.isSupporter)
        entitlement.set(false)
        XCTAssertFalse(entitlement.isSupporter)
    }

    func test_valuePersistsAcrossInstances() {
        SupporterEntitlement(defaults: defaults).set(true)
        XCTAssertTrue(SupporterEntitlement(defaults: defaults).isSupporter)
    }
}
