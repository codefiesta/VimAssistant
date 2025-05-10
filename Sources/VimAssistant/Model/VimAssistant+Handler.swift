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
            guard prediction.entities.isNotEmpty else { return }

            let action = bestPrediction.action

            guard let db = vim.db else { return }
            let modelContext = ModelContext(db.modelContainer)

            var ids: Set<Int> = .init()

            // TODO: This needs reworked but predicate disjunction is way effin complicated.
            let predicates = buildPredicates(prediction: prediction)
            let descriptor = FetchDescriptor<Database.Node>(sortBy: [SortDescriptor(\.index)])
            guard let results = try? modelContext.fetch(descriptor), results.isNotEmpty else { return }

            for predicate in predicates {
                guard let filtered = try? results.filter(predicate) else { continue }
                ids.formUnion(filtered.compactMap{ Int($0.index) })
            }

            guard ids.isNotEmpty else { return }

            Task {
                switch action {
                case .hide:
                    await vim.hide(ids: ids.sorted())
                case .isolate:
                    await vim.isolate(ids: ids.sorted())
                case .quantify:
                    break
                }
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
