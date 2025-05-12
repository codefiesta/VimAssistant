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
                    vim.zoom()
                case .zoomOut:
                    vim.zoom(out: true)
                case .lookLeft:
                    vim.look(.left)
                case .lookRight:
                    vim.look(.right)
                case .lookUp:
                    vim.look(.up)
                case .lookDown:
                    vim.look(.down)
                case .panLeft:
                    vim.pan(.left)
                case .panRight:
                    vim.pan(.right)
                case .panUp:
                    vim.pan(.up)
                case .panDown:
                    vim.pan(.down)
                }
            }
        }

        private func collect(vim: Vim, prediction: VimPrediction) -> [Int] {

            guard let bestPrediction = prediction.bestPrediction, prediction.entities.isNotEmpty else { return []}
            let action = bestPrediction.action

            switch action {
            case .hide, .isolate:
                guard let db = vim.db, db.nodes.isNotEmpty else { return [] }
                let modelContext = ModelContext(db.modelContainer)

                var ids: Set<Int> = .init()

                // Fetch all geometry nodes
                let nodes = db.nodes
                let predicate = Database.Node.predicate(nodes: nodes)
                let descriptor = FetchDescriptor<Database.Node>(predicate: predicate, sortBy: [SortDescriptor(\.index)])
                guard let results = try? modelContext.fetch(descriptor), results.isNotEmpty else { return [] }

                let categoryNames = prediction.entities.filter{ $0.label == .bimCategory }.map { $0.value }
                let familyNames = prediction.entities.filter{ $0.label == .bimFamily }.map { $0.value }

                // Tuple of category names and ids
                let categories = results.compactMap{ $0.element?.category?.name }.uniqued().sorted{ $0 < $1 }.map { name in
                    (name: name, ids: results.filter{ $0.element?.category?.name == name}.compactMap{ Int($0.index) })
                }

                // Tuple of family names and ids
                let familes = results.compactMap{ $0.element?.familyName }.uniqued().sorted{ $0 < $1 }.map { name in
                    (name: name, ids: results.filter{ $0.element?.familyName == name}.compactMap{ Int($0.index) })
                }

                // Collect the ids of the matching categories
                for name in categoryNames {
                    let found = categories.filter{ name.localizedStandardContains($0.name) }.map{ $0.ids }.reduce([], +)
                    ids.formUnion(found)
                }

                // Collect the ids of the matching families
                for name in familyNames {
                    let found = familes.filter{ name.localizedStandardContains($0.name) }.map{ $0.ids }.reduce([], +)
                    ids.formUnion(found)
                }
                return ids.sorted()
            case .quantify, .zoomIn, .zoomOut, .lookLeft, .lookRight, .lookUp, .lookDown, .panLeft, .panRight, .panUp, .panDown:
                return []
            }

        }
    }
}

extension Array where Element == String {
    func containsIgnoringCase(_ element: Element) -> Bool {
        contains { $0.caseInsensitiveCompare(element) == .orderedSame }
    }
}
