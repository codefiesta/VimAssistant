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

            print("❤️", bestPrediction)

            for entity in prediction.entities {
                if entity.label == "CON-BIM-CATG" {
                    print("🚀", entity.value)
                    perform(vim: vim, action: action, category: entity.value)
                } else if entity.label == "CON-BIM-FAML" {

                } else if entity.label == "CON-BIM-TYPE" {

                }
            }
        }

        private func perform(vim: Vim, action: VimPrediction.Action, category: String) {

            guard let db = vim.db else { return }
            let modelContext = ModelContext(db.modelContainer)

            let orderedSame = ComparisonResult.orderedSame
            let predicate = #Predicate<Database.Node>{
                if let element = $0.element, let cat = element.category {
                    return cat.name.caseInsensitiveCompare(category) == orderedSame
                } else {
                    return false
                }
            }

            let descriptor = FetchDescriptor<Database.Node>(predicate: predicate, sortBy: [SortDescriptor(\.index)])
            guard let results = try? modelContext.fetch(descriptor), results.isNotEmpty else { return }
            let ids = results.compactMap{ Int($0.index) }
            Task {
                switch action {
                case .hide:
                    await vim.hide(ids: ids)
                case .isolate:
                    await vim.isolate(ids: ids)
                case .quantify:
                    break
                }
            }
        }

    }
}
