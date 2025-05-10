//
//  VimAssistant+Handler.swift
//  VimAssistant
//
//  Created by Kevin McKee
//

import Foundation
import SwiftData
import VimKit

public extension VimAssistant {

    struct Handler {

        /// Handles the received
        /// - Parameters:
        ///   - vim: the vim object to use
        ///   - prediction: the prediction
        func handle(vim: Vim, prediction: VimPrediction?) {
            guard let prediction, let bestPrediction = prediction.bestPrediction, bestPrediction.confidence >= 0.85 else { return }
            let action = bestPrediction.action
            let ids = collect(vim: vim, prediction: prediction)
            Task { @MainActor in
                switch action {
                case .hide:
                    guard ids.isNotEmpty else { return }
                    await vim.hide(ids: ids)
                case .isolate:
                    guard ids.isNotEmpty else { return }
                    await vim.isolate(ids: ids)
                case .quantify:
                    // TODO: Probably just emit an event that shows the quantities view
                    break
                case .zoomIn:
                    await vim.zoom()
                case .zoomOut:
                    await vim.zoom(out: true)
                case .lookLeft:
                    await vim.look(.left)
                case .lookRight:
                    await vim.look(.right)
                case .lookUp:
                    await vim.look(.up)
                case .lookDown:
                    await vim.look(.down)
                case .panLeft:
                    await vim.pan(.left)
                case .panRight:
                    await vim.pan(.right)
                case .panUp:
                    await vim.pan(.up)
                case .panDown:
                    await vim.pan(.down)
                }
            }
        }

        private func collect(vim: Vim, prediction: VimPrediction) -> [Int] {

            guard let bestPrediction = prediction.bestPrediction, prediction.entities.isNotEmpty else { return []}
            let action = bestPrediction.action

            switch action {
            case .hide, .isolate:
                guard let db = vim.db else { return [] }
                let modelContext = ModelContext(db.modelContainer)

                var ids: Set<Int> = .init()

                // TODO: This is highly inefficient and needs reworked but predicate disjunction is way effin complicated and frankly stupid.
                let predicates = buildPredicates(prediction: prediction)
                let descriptor = FetchDescriptor<Database.Node>(sortBy: [SortDescriptor(\.index)])
                guard let results = try? modelContext.fetch(descriptor), results.isNotEmpty else { return [] }

                for predicate in predicates {
                    guard let filtered = try? results.filter(predicate) else { continue }
                    ids.formUnion(filtered.compactMap{ Int($0.index) })
                }
                return ids.sorted()
            case .quantify, .zoomIn, .zoomOut, .lookLeft, .lookRight, .lookUp, .lookDown, .panLeft, .panRight, .panUp, .panDown:
                return []
            }

        }

        /// Builds a node predicate that matches on category name.
        /// - Parameter name: the category name to match
        /// - Returns: a predicate that matches case insensitive category name
        private func buildCategoryPredicate(_ name: String) -> Predicate<Database.Node> {
            let predicate = #Predicate<Database.Node> { node in
                if let element = node.element, let category = element.category {
                    return category.name.localizedStandardContains(name)
                } else {
                    return false
                }
            }
            return predicate
        }

        /// Builds a node predicate that matches on family name.
        /// - Parameter name: the family name to match
        /// - Returns: a predicate that matches case insensitive family name
        private func buildFamilyPredicate(_ name: String) -> Predicate<Database.Node> {
            let predicate = #Predicate<Database.Node> { node in
                if let element = node.element, let familyName = element.familyName {
                    return familyName.localizedStandardContains(name)
                } else {
                    return false
                }
            }
            return predicate
        }

        /// Builds a list of predicates to query on based on the given prediction.
        /// - Parameter prediction: the prediction to use
        /// - Returns: a list of node predicates
        private func buildPredicates(prediction: VimPrediction) -> [Predicate<Database.Node>] {
            let categories = prediction.entities.filter{ $0.label == .bimCategory }.map { $0.value }
            let families = prediction.entities.filter{ $0.label == .bimFamily }.map { $0.value }
            let categoryPredicates = categories.map { buildCategoryPredicate($0) }
            let familyPredicates = families.map { buildFamilyPredicate($0) }
            let predicates = categoryPredicates + familyPredicates
            return predicates
        }
    }
}

extension Array where Element == String {
    func containsIgnoringCase(_ element: Element) -> Bool {
        contains { $0.caseInsensitiveCompare(element) == .orderedSame }
    }
}
