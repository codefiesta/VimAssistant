//
//  VimPredictionView.swift
//  VimAssistant
//
//  Created by Kevin McKee
//

import SwiftUI

struct VimPredictionView: View {

    let prediction: VimPrediction

    var text: String { prediction.text }

    /// Returns the colors for their corresponding range
    private var confidenceColors: [Color] {
        [
            .red,
            .orange,
            .yellow,
            .green
        ]
    }

    /// Returns the ranges of culling percengtages.
    private var confidenceRanges: [Range<Float>] {
        [
            0.0..<0.85,
            0.85..<0.9,
            0.9..<0.95,
            0.95..<1.01
        ]
    }

    /// Returns the prediction confidence color.
    var predictionConfidenceColor: Color {
        guard let bestPrediction = prediction.bestPrediction else {
            return .primary
        }
        for (i, range) in confidenceRanges.enumerated() {
            if range.contains(bestPrediction.confidence) {
                return confidenceColors[i]
            }
        }
        return .primary
    }


    @Binding
    var explain: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text(attributedString)
            explanationView
                .frame(height: explain ? nil : 0, alignment: .top)
                .clipped()
        }
        .padding()
        .environment(\.openURL, OpenURLAction { url in
            withAnimation {
                explain.toggle()
            }
            return .discarded
        })
    }

    var attributedString: AttributedString {
        var result = AttributedString(text)
        for entity in prediction.entities {
            let entityText = text[entity.range]
            var attributedEntityString = AttributedString(entityText)
            attributedEntityString.foregroundColor = entity.label.color
            attributedEntityString.underlineStyle = .single
            attributedEntityString.link = URL(string: "/\(entity.label)/\(entity.value)")!
            result.replaceSubrange(bounds: entity.range, with: attributedEntityString)
        }
        return result
    }

    var bestPredictionView: some View {
        HStack {
            if let bestPrediction = prediction.bestPrediction {
                Text(bestPrediction.action.rawValue.lowercased())
                Text(bestPrediction.confidence.formatted())
            }
        }
    }

    var explanationView: some View {
        VStack(alignment: .leading) {
            Text("Explanation of results")
                .font(.headline)
            Divider()
                .fixedSize()

            if prediction.entities.isNotEmpty {
                Text("Recognized entities:")
                    .font(.subheadline).bold()
            }
            ForEach(prediction.entities) { entity in
                HStack {
                    Text(text[entity.range])
                        .bold()
                    Text(entity.label.rawValue)
                        .padding(1)
                        .background(entity.label.color)
                        .foregroundStyle(Color.black)
                        .cornerRadius(2)
                }
            }
            if let bestPrediction = prediction.bestPrediction {
                Divider()
                    .fixedSize()
                Text("Best prediction action:")
                    .font(.subheadline)
                    .bold()
                HStack {
                    Text(bestPrediction.action.rawValue.lowercased())
                        .bold()
                    Text(bestPrediction.confidence.formatted(.percent.precision(.fractionLength(2))))
                        .foregroundStyle(predictionConfidenceColor)
                }
            }

        }
        .padding([.top])
    }
}

#Preview {

    let json = "{\"text\":\"Hide all walls and air terminals \",\"ents\":[{\"start\":9,\"end\":14,\"label\":\"CON_BIM_CATG\"},{\"start\":19,\"end\":32,\"label\":\"CON_BIM_CATG\"}],\"cats\":{\"ISOLATE\":0.0122569752857089,\"HIDE\":0.978784739971161,\"QUANTIFY\":0.00895828753709793}}"
    let prediction = try! JSONDecoder().decode(VimPrediction.self, from: json.data(using: .utf8)!)
    VimPredictionView(prediction: prediction, explain: .constant(true))
}

extension VimPrediction.NerLabel {

    var color: Color {
        switch self {
        case .person:
            .purple
        case .organization:
            .blue
        case .location:
            .black
        case .date:
            .mint
        case .time:
            .cyan
        case .event:
            .cyan
        case .workOfArt:
            .cyan
        case .fac:
            .cyan
        case .gpe:
            .cyan
        case .language:
            .cyan
        case .law:
            .cyan
        case .norp:
            .cyan
        case .product:
            .cyan
        case .cardinal:
            .blue
        case .bimCategory:
            .cyan
        case .bimFamily:
            .orange
        case .bimType:
            .cyan
        case .bimInstance:
            .cyan
        case .bimLevel:
            .yellow
        case .bimView:
            .cyan
        }
    }
}
