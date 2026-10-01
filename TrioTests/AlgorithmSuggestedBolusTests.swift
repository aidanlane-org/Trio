import Foundation
import Testing
@testable import Trio

@Suite("Algorithm Suggested Bolus") struct AlgorithmSuggestedBolusTests {
    private func suggestion(
        insulinRequired: Decimal,
        fraction: Decimal = 0.8,
        maxBolus: Decimal = 10,
        dosingMode: DosingMode = .open
    ) -> Decimal {
        let state = Treatments.StateModel()
        state.insulinRequired = insulinRequired
        state.fraction = fraction
        state.maxBolus = maxBolus
        state.dosingMode = dosingMode
        return state.algorithmSuggestedBolus
    }

    @Test("Discounted by the Recommended Bolus Percentage") func appliesFraction() {
        #expect(suggestion(insulinRequired: 2) == 1.6)
        #expect(suggestion(insulinRequired: 2, fraction: 0.5) == 1)
    }

    @Test("Capped at Max Bolus") func respectsMaxBolus() {
        #expect(suggestion(insulinRequired: 100, maxBolus: 6) == 6)
    }

    @Test("Nothing to suggest when the algorithm wants no insulin") func nonPositiveRequirement() {
        #expect(suggestion(insulinRequired: 0) == 0)
        // oref returns a negative requirement when it wants basal reduced, which is not a bolus.
        #expect(suggestion(insulinRequired: -1.5) == 0)
    }

    @Test("Only in open loop, since every other mode lets the loop act on it") func openLoopOnly() {
        #expect(suggestion(insulinRequired: 2, dosingMode: .open) == 1.6)
        // Closed loop already delivers insulinReq as SMBs or a high temp, so a manual bolus would double it.
        #expect(suggestion(insulinRequired: 2, dosingMode: .closed) == 0)
        #expect(suggestion(insulinRequired: 2, dosingMode: .lowGlucoseSuspend) == 0)
        #expect(suggestion(insulinRequired: 2, dosingMode: .basalTesting) == 0)
    }
}
