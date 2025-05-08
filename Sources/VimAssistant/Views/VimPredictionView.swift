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

    var colors: [Color] = [
        .red, .orange, .teal, .purple, .blue, .green,
    ]

    @State
    var isDisclosed: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            Text(attributedString)
            explanationView
                .frame(height: isDisclosed ? nil : 0, alignment: .top)
                .clipped()
        }
        .padding()
        .environment(\.openURL, OpenURLAction { url in
            withAnimation {
                isDisclosed.toggle()
            }
            return .discarded
        })
    }

    var attributedString: AttributedString {
        var result = AttributedString(text)
        for entity in prediction.entities {
            let entityText = text[entity.range]
            var attributedEntityString = AttributedString(entityText)
            attributedEntityString.foregroundColor = .orange
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

            Text("Recognized entities:")
                .font(.subheadline).bold()
            ForEach(prediction.entities) { entity in
                HStack {
                    Text(text[entity.range])
                        .bold()
                    Text(entity.label)
                        .padding(2)
                        .background(Color.orange)
                        .cornerRadius(4)
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
                    Text(bestPrediction.confidence.formatted(.percent))
                }
            }

        }
        .padding([.top])
    }
}

#Preview {

    let json = "{\"text\":\"Hide all walls and air terminals \",\"ents\":[{\"start\":9,\"end\":14,\"label\":\"CON-BIM-CATG\"},{\"start\":19,\"end\":32,\"label\":\"CON-BIM-CATG\"}],\"cats\":{\"ISOLATE\":0.0122569752857089,\"HIDE\":0.978784739971161,\"QUANTIFY\":0.00895828753709793}}"
    let prediction = try! JSONDecoder().decode(VimPrediction.self, from: json.data(using: .utf8)!)
    VimPredictionView(prediction: prediction)
}
