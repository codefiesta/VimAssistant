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

    var body: some View {
        annotatedText
            .frame(alignment: .leading)
                .padding()
    }

    var annotatedText: some View {
        HStack(spacing: 0) {
            ForEach(prediction.ranges, id: \.1) { item in
                if item.index == .empty {
                    Text(text[item.range])
                } else {
                    Text(text[item.range])
                    .padding(6)
                    .background(Color.purple.opacity(0.65))
                    .cornerRadius(8)
                }
            }
        }
    }
}

#Preview {

    let json = "{\"text\":\"Hide all walls and air terminals \",\"ents\":[{\"start\":9,\"end\":14,\"label\":\"CON-BIM-CATG\"},{\"start\":19,\"end\":32,\"label\":\"CON-BIM-CATG\"}],\"cats\":{\"ISOLATE\":0.0122569752857089,\"HIDE\":0.978784739971161,\"QUANTIFY\":0.00895828753709793}}"
    let prediction = try! JSONDecoder().decode(VimPrediction.self, from: json.data(using: .utf8)!)
    VimPredictionView(prediction: prediction)
}
