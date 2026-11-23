//
//  FittingLinesLayout.swift
//  PoeticWidgets
//
//  Created by Dean Thompson on 2026/11/23.
//

import SwiftUI

/// Marks the optional "…" view at the end of a `FittingLinesLayout`.
struct IsMoreMarker: LayoutValueKey {
    static let defaultValue = false
}

/// Stacks poem lines top to bottom and shows only the lines that fit
/// completely in the height on offer. Each line may wrap at the real widget
/// width, so nothing is truncated mid-line and no line is shrunk – every line
/// keeps the same font size. Lines that don't fit are left out whole.
///
/// An optional trailing marker (a subview tagged with `IsMoreMarker`) is
/// shown, with room reserved for it, only when the poem continues beyond
/// what's visible: lines were left out here, or `poemContinues` is set
/// because the excerpt itself stops before the poem's end. If not even one
/// line fits, nothing is shown (no lone marker).
struct FittingLinesLayout: Layout {
    var spacing: CGFloat = 2
    var poemContinues = false

    private struct Plan {
        /// Height for each subview that is shown, keyed by subview index.
        var heights: [Int: CGFloat] = [:]
        var totalHeight: CGFloat = 0
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 320
        let plan = makePlan(width: width, height: proposal.height ?? .infinity, subviews: subviews)
        return CGSize(width: width, height: plan.totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let plan = makePlan(width: bounds.width, height: bounds.height, subviews: subviews)
        var cursorY = bounds.minY
        for index in subviews.indices {
            if let height = plan.heights[index] {
                subviews[index].place(
                    at: CGPoint(x: bounds.minX, y: cursorY),
                    proposal: ProposedViewSize(width: bounds.width, height: height)
                )
                cursorY += height + spacing
            } else {
                // Left out: park it outside the (clipped) bounds at zero size.
                subviews[index].place(
                    at: CGPoint(x: bounds.minX, y: bounds.maxY + 10_000),
                    proposal: .zero
                )
            }
        }
    }

    private func makePlan(width: CGFloat, height: CGFloat, subviews: Subviews) -> Plan {
        let unconstrained = ProposedViewSize(width: width, height: nil)
        let markerIndex = subviews.indices.first { subviews[$0][IsMoreMarker.self] }
        let lineIndices = subviews.indices.filter { $0 != markerIndex }
        let lineHeights = lineIndices.map { subviews[$0].sizeThatFits(unconstrained).height }
        let markerHeight = markerIndex.map { subviews[$0].sizeThatFits(unconstrained).height } ?? 0

        func stackHeight(_ heights: [CGFloat]) -> CGFloat {
            heights.isEmpty ? 0 : heights.reduce(0, +) + spacing * CGFloat(heights.count - 1)
        }

        var plan = Plan()
        // Everything fits and the poem ends here: show it all, no marker.
        if !poemContinues, stackHeight(lineHeights) <= height {
            for (index, lineHeight) in zip(lineIndices, lineHeights) {
                plan.heights[index] = lineHeight
            }
            plan.totalHeight = stackHeight(lineHeights)
            return plan
        }
        // Otherwise reserve room for the marker and take whole lines in order.
        let reserve = markerIndex == nil ? 0 : markerHeight + spacing
        var used: CGFloat = 0
        var shown: [CGFloat] = []
        for (index, lineHeight) in zip(lineIndices, lineHeights) {
            let next = used + (shown.isEmpty ? 0 : spacing) + lineHeight
            guard next + reserve <= height else { break }
            used = next
            shown.append(lineHeight)
            plan.heights[index] = lineHeight
        }
        // A marker under zero lines would just be a stray "…": show nothing.
        if let markerIndex, !shown.isEmpty {
            plan.heights[markerIndex] = markerHeight
            shown.append(markerHeight)
        }
        plan.totalHeight = stackHeight(shown)
        return plan
    }
}
